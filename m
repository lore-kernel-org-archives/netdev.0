From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Fri, 03 Aug 2007 17:51:42 +0100
Message-ID: <46B35D1E.9050501@simon.arlott.org.uk>
References: <36758.simon.1186054739@5ec7c279.invalid> <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv> <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk> <20070803082517.GB25582@2ka.mipt.ru> <46956.simon.1186140106@5ec7c279.invalid> <20070803115624.GD5727@2ka.mipt.ru> <60580.simon.1186142626@5ec7c279.invalid> <20070803120920.GA23166@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070703090004010308040704"
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:49583 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbXHCQvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 12:51:47 -0400
In-Reply-To: <20070803120920.GA23166@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070703090004010308040704
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 03/08/07 13:09, Evgeniy Polyakov wrote:
> On Fri, Aug 03, 2007 at 01:03:46PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
>> On Fri, August 3, 2007 12:56, Evgeniy Polyakov wrote:
>> > On Fri, Aug 03, 2007 at 12:21:46PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
>> >> Since the connection is considered closed, couldn't another socket re-use it?
>> >>
>> >> Socket A: Recv data (unread)
>> >> Socket A: Recv RST
>> >> Socket B: Reuses connection (same IPs/ports)
>> >> Socket A: Close
>> >>
>> >> Wouldn't that disrupt socket B's use of the connection?
>> >
>> > Then it will drop our data, since there were no appropriate handhsake.
>> 
>> Couldn't the sequence numbers be close enough to make the RST valid?
> 
> It does not matter - if connection is not in synchronized state all
> unrelated data is dropped, so remote side is only allowed to receive syn
> flag only, anything else must be dropped. If remote side does not do
> that, it violates RFC.

Except the remote side has a connection, because another one can be made 
before the existing connection is closed:

17:37:37.377571 IP 192.168.7.4.50550 > 192.168.7.8.2500: S 134077329:134077329(0) win 1500 (raw)
17:37:37.382352 IP 192.168.7.8.2500 > 192.168.7.4.50550: S 3460060233:3460060233(0) ack 134077330 win 14360 <mss 7180> (accept)
17:37:37.377966 IP 192.168.7.4.50550 > 192.168.7.8.2500: . ack 1 win 1500 (raw)
17:37:37.378128 IP 192.168.7.4.50550 > 192.168.7.8.2500: P 1:17(16) ack 1 win 1500 (raw)
17:37:37.378162 IP 192.168.7.8.2500 > 192.168.7.4.50550: . ack 17 win 14360
17:37:37.378131 IP 192.168.7.4.50550 > 192.168.7.8.2500: R 134077346:134077346(0) win 1500 (raw)

17:37:37.412709 IP 192.168.7.4.50550 > 192.168.7.8.2500: SWE 3257207813:3257207813(0) win 14280 <mss 7140,sackOK,timestamp 3601441543 0,nop,wscale 5> (connect)
17:37:37.412785 IP 192.168.7.8.2500 > 192.168.7.4.50550: SE 3495384256:3495384256(0) ack 3257207814 win 14336 <mss 7180,sackOK,timestamp 4294812905 3601441543,nop,wscale 6> (accept)
17:37:37.412960 IP 192.168.7.4.50550 > 192.168.7.8.2500: . ack 1 win 447 <nop,nop,timestamp 3601441543 4294812905>

17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360 (close (previous connection))

17:37:47.417649 IP 192.168.7.8.2500 > 192.168.7.4.50550: F 1:1(0) ack 1 win 224 <nop,nop,timestamp 4294822910 3601441543> (close)
17:37:47.417993 IP 192.168.7.4.50550 > 192.168.7.8.2500: F 1:1(0) ack 2 win 447 <nop,nop,timestamp 3601444045 4294822910> (read returned)
17:37:47.418466 IP 192.168.7.8.2500 > 192.168.7.4.50550: . ack 2 win 224 <nop,nop,timestamp 4294822911 3601444045>


The second connection also modified the RST|ACK that was sent compared to no second connection:

17:38:03.532703 IP 192.168.7.4.50550 > 192.168.7.8.2500: S 82517575:82517575(0) win 1500 (raw)
17:38:03.532832 IP 192.168.7.8.2500 > 192.168.7.4.50550: S 3495449795:3495449795(0) ack 82517576 win 14360 <mss 7180> (accept)
17:38:03.533388 IP 192.168.7.4.50550 > 192.168.7.8.2500: . ack 1 win 1500 (raw)
17:38:03.533457 IP 192.168.7.4.50550 > 192.168.7.8.2500: P 1:17(16) ack 1 win 1500 (raw)
17:38:03.533597 IP 192.168.7.8.2500 > 192.168.7.4.50550: . ack 17 win 14360
17:38:03.533589 IP 192.168.7.4.50550 > 192.168.7.8.2500: R 82517592:82517592(0) win 1500 (raw)

17:38:04.536277 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 1:1(0) ack 17 win 14360 (close)


17:38:04.536277 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 1:1(0) ack 17 win 14360
vs
17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360
What happened there ?


On the server, run tcptest-server.c, which waits for 1s on the first connection then 10s on the second connection.

On the client, run:
iptables -I INPUT -i eth0 -p tcp --dport 50550 -j DROP; ./client; iptables -D INPUT -i eth0 -p tcp --dport 50550 -j DROP; ./tcptest-client

(client.c from john's original email)

-- 
Simon Arlott


--------------070703090004010308040704
Content-Type: text/x-csrc;
 name="tcptest-server.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcptest-server.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <poll.h>
#include <fcntl.h>

#define PORT 2500

#define xerror(str) do { perror(str); exit(1); } while (0)

int main(void) {
	struct sockaddr_in sa;
	int l, s, tmp;
	int t = 0;

	memset(&sa, 0, sizeof(sa));
	
	l = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (!l)
		xerror("socket");
		
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = htonl(INADDR_ANY);
	sa.sin_port = htons(PORT);

	tmp = 1;
	setsockopt(l, SOL_SOCKET, SO_REUSEADDR, (char*)&tmp, sizeof(tmp));

	if (bind(l, (struct sockaddr*)&sa, sizeof(sa)) != 0)
		xerror("bind");

	if (listen(l, 0) != 0)
		xerror("listen");

	printf("server %d ready...\n", getpid());

	for (t = 1; t <= 2; t++) {
		s = accept(l, NULL, NULL);
		switch (fork()) {
			case -1:
				xerror("fork");
				break;
			case 0:
				switch (t) {
					case 1:
						printf("server %d accepted connection\n", getpid());

#if 0
						tmp = fcntl(s, F_GETFL, 0);
						if (fcntl(s, F_SETFL, tmp | O_NONBLOCK) != 0)
							xerror("fcntl");

						if (send(s, "AAAAAAA", 7, 0) != 7)
							xerror("send");
#endif

						printf("server %d waiting for 1 second...\n", getpid());
							
						sleep(1);
						
						
						printf("server %d closing connection\n", getpid());
						
						close(s);
						
						
						return 0;
						break;

					case 2:
						printf("server %d accepted connection\n", getpid());
						printf("server %d waiting for 10 seconds...\n", getpid());

						sleep(10);


						printf("server %d closing connection\n", getpid());
						
						close(s);
						
						
						return 0;
						break;
				}
				break;
			default:
				close(s);
		}
	}

	wait(NULL);
	wait(NULL);
	return 0;
}

--------------070703090004010308040704
Content-Type: text/x-csrc;
 name="tcptest-client.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcptest-client.c"

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define SERVER_IP "192.168.7.8"
#define SRC_PORT 50550
#define DST_PORT 2500

#define xerror(str) do { perror(str); exit(1); } while (0)

int main(void) {
	struct sockaddr_in sa;
	int s;
	int t = 0;
	char buf[32];
	int ret, tmp;

	memset(&sa, 0, sizeof(sa));
	
	for (t = 1; t <= 1; t++) {
		switch (fork()) {
			case -1:
				xerror("fork");
				break;
			case 0:
				printf("client %d binding port...\n", getpid());

				s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
				if (!s)
					xerror("socket");

				sa.sin_family = AF_INET;
				sa.sin_addr.s_addr = htonl(INADDR_ANY);
				sa.sin_port = htons(SRC_PORT);

				tmp = 1;
				if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, (char*)&tmp, sizeof(tmp)) != 0)
					xerror("setsockopt");

				if (bind(s, (struct sockaddr*)&sa, sizeof(sa)) != 0)
					xerror("bind");


				printf("client %d connecting...\n", getpid());

				sa.sin_family = AF_INET;
				sa.sin_addr.s_addr = inet_addr(SERVER_IP);
				sa.sin_port = htons(DST_PORT);

				if (connect(s, (struct sockaddr*)&sa, sizeof(sa)) != 0)
					xerror("connect");

				printf("client %d waiting in read()...\n", getpid());

				ret = read(s, buf, 32);
				printf("client %d read() returned %d\n", getpid(), ret);

				close(s);

				return 0;
		}

		wait(NULL);
	}

	return 0;
}

--------------070703090004010308040704--
