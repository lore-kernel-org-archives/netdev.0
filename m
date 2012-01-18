From: Flavio Leitner <fbl@redhat.com>
Subject: bind()/inet_csk_get_port() fails when no port is requested
Date: Wed, 18 Jan 2012 15:11:26 -0200
Message-ID: <20120118151126.01a74dc5@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcelo Leitner <mleitner@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932214Ab2ARRL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 12:11:29 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q0IHBTmM012310
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 12:11:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi folks,

It has been reported to me that bind() fails when you leave
the port up to the kernel to choose and succeed when you
request a certain port in the same conditions.

For example, let's restrict the ephemeral port range to 3 ports only:
# echo "32768 32770" > /proc/sys/net/ipv4/ip_local_port_range

Assuming the system has two IP addresses: 172.31.1.6/24 and
192.168.100.6/24 then run the following python script which
allocates all ephemeral ports using one IP address and then
try to bind another one using another IP address.

#!/usr/bin/python
import socket
ip1 = []
s = None
for i in [ 1, 2, 3, 4, 5, 6 ]:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP)
        try:
                s.bind(('172.31.1.7', 0))
                ip1.append(s)
        except socket.error, err: # socket.error: (98, 'Address already in use')
                if err.args[0] == 98:
                        break
                else:
                        raise

print '%d sockets bound at 172.31.1.7' % len(ip1)
print 'Now binding at 192.168.100.6'

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP)
s.bind(('192.168.100.6', 0))

This is the result:
# ./ephemeral.py 
3 sockets bound at 172.31.1.6
Now binding at 192.168.100.6
Traceback (most recent call last):
  File "./ephemeral.py", line 23, in <module>
    s.bind(('192.168.100.6', 0))
  File "/usr/lib64/python2.7/socket.py", line 224, in meth
    return getattr(self._sock,name)(*args)
socket.error: [Errno 98] Address already in use

The last bind() fails even using a different IP address.
Now if we change the reproducer to use fixed port number instead:

#!/usr/bin/python
import socket
ip1 = []
s = None
first_port=32768
port=first_port
for i in [ 1, 2, 3, 4, 5, 6 ]:
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP)
	try:
		s.bind(('172.31.1.7', port))
		ip1.append(s)
	except socket.error, err: # socket.error: (98, 'Address already in use')
		if err.args[0] == 98:
			break
		else:
			raise
	port = port + 1

print '%d sockets bound at 172.31.1.7' % len(ip1)
print 'Now binding at 192.168.100.6'

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM, socket.IPPROTO_TCP)
s.bind(('192.168.100.6', first_port))

This is the result:
# ./fixedports.py 
6 sockets bound at 172.31.1.7
Now binding at 192.168.100.6   <-- works out!

Conclusion: When using ephemeral ports, inet_csk_get_port()
fails without checking if a conflict had happened. When using
fixed ports on the other hand, inet_csk_get_port() works
as expected.

I will attach a quick hack to illustrate what I am thinking.
The idea is to check all ports first and if it fails, then
try again looking for a port that doesn't conflict. So, for
most cases, the algorithm is the same, but when the system
ran out of ports, there is a hope :-)

Is there a reason to behave like that? or is this a real bug?
Sounds like a FAQ, but I am not finding an explanation for this
on the net yet.

*hack*
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 2e4e244..2911f06 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -97,7 +97,9 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	int ret, attempts = 5;
 	struct net *net = sock_net(sk);
 	int smallest_size = -1, smallest_rover;
+	bool check_conflict;
 
+	check_conflict = false;
 	local_bh_disable();
 	if (!snum) {
 		int remaining, rover, low, high;
@@ -128,6 +130,13 @@ again:
 							goto have_snum;
 						}
 					}
+
+					if (check_conflict && !inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
+						spin_unlock(&head->lock);
+						snum = rover;
+						goto have_snum;
+					}
+
 					goto next;
 				}
 			break;
@@ -150,6 +159,11 @@ again:
 				snum = smallest_rover;
 				goto have_snum;
 			}
+			/* try again checking if a port can be reused */
+			if (!check_conflict) {
+				check_conflict = true;
+				goto again;
+			}
 			goto fail;
 		}
 		/* OK, here is the one we will use.  HEAD is

thanks,
fbl
