From: Mike McCormack <mike@codeweavers.com>
Subject: Patch to count the number of datagrams in a unix domain socket
Date: Mon, 04 Apr 2005 19:51:29 +0900
Message-ID: <42511C31.3090801@codeweavers.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040700050107080907080805"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040700050107080907080805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Hi,

I trying to implement mailslot support in Wine, and have come across a 
small problem that isn't easy to solve.  My implementation [1] uses a 
unix domain socket in dgram mode.

The Win32 function GetMailslotInfo [2] allows a program to fetch the 
number of messages waiting in the mailslot.  In my implementation, that 
is the number of datagrams waiting in the socket.

In Linux 2.6.11 there is no way to count the the number of datagrams in 
a socket without reading them all out, one by one.   I have attached a 
small patch that lets me read the number of datagrams in a socket, and 
makes GetMailslotInfo work in my test case [3].

Questions:

Do people thing this is something useful to add to the kernel?

What's the right way to assign a value for SIOCINCOUNT, and in which 
header?  Is SIOCDGRAMCOUNT or something else a better name?

Should the return value of SIOCINCOUNT for a non-dgram socket be different?

If I add this ioctl() for unix domain sockets, should other sockets be 
made to work the same way?

thanks,

Mike



[1] http://cvs.winehq.org/cvsweb/wine/server/mailslot.c
[2] 
http://msdn.microsoft.com/library/default.asp?url=/library/en-us/ipc/base/getmailslotinfo.asp
[3] http://cvs.winehq.org/cvsweb/wine/dlls/kernel/tests/mailslot.c

--------------040700050107080907080805
Content-Type: text/x-patch;
 name="siocincount.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="siocincount.diff"

--- linux-2.6.11-orig/net/unix/af_unix.c	2005-03-02 16:38:12.000000000 +0900
+++ linux-2.6.11/net/unix/af_unix.c	2005-04-03 16:36:52.000000000 +0900
@@ -1838,6 +1838,7 @@
 static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
+	struct sk_buff *skb;
 	long amount=0;
 	int err;
 
@@ -1848,8 +1849,6 @@
 			err = put_user(amount, (int __user *)arg);
 			break;
 		case SIOCINQ:
-		{
-			struct sk_buff *skb;
 
 			if (sk->sk_state == TCP_LISTEN) {
 				err = -EINVAL;
@@ -1869,8 +1868,21 @@
 			spin_unlock(&sk->sk_receive_queue.lock);
 			err = put_user(amount, (int __user *)arg);
 			break;
-		}
 
+#define SIOCINCOUNT 0x8907
+		case SIOCINCOUNT:
+			/* count the number of packets waiting */
+			if (sk->sk_state == TCP_LISTEN) {
+				err = -EINVAL;
+				break;
+			}
+
+			spin_lock(&sk->sk_receive_queue.lock);
+			skb_queue_walk(&sk->sk_receive_queue, skb)
+				amount++;
+			spin_unlock(&sk->sk_receive_queue.lock);
+			err = put_user(amount, (int __user *)arg);
+			break;
 		default:
 			err = dev_ioctl(cmd, (void __user *)arg);
 			break;

--------------040700050107080907080805--
