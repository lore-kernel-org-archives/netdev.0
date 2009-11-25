From: Asdo <asdo@shiftmail.org>
Subject: TCP sockets stalling - help! (long)
Date: Wed, 25 Nov 2009 05:25:28 +0100
Message-ID: <4B0CB1B8.8030402@shiftmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.isti.cnr.it ([194.119.192.4]:2439 "EHLO mx2.isti.cnr.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934427AbZKYE0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 23:26:16 -0500
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.4 #31773)
 id <01NGHY18H3Y89OGFPH@mx.isti.cnr.it> for netdev@vger.kernel.org; Wed,
 25 Nov 2009 05:25:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev and e1000 people,

I have a weird problem here.

We have a Linux "Storage" server acting as a Samba, SCP and SFTP 
fileserver. All clients are Windows: XP and Vista, 32 and 64 bits. The 
building has gigabit network. We transfer up to many TB at a time.

I have tried from many clients to the same Server and there is always 
the same problem: after hours that a transfer is running the TCP socket 
suddenly stalls: 0 bytes/sec. It doesn't slow down, it stalls suddenly. 
It never disconnects though.

 From that moment onward, the TCP socket stays in a stalling condition 
forever (I saw myself at least 10 hours) and both sides see it 
Established forever. This is in case of no other networking activity on 
the same network card.
In case of other networking activity someone told me that he did see the 
transfer restart (=continue) by itself (it was an SFTP that time). I 
think I saw this phenomenon myself once during the tcpdump at the bottom 
of this email.

This problem happens on every protocol (Samba, SCP, SFTP) and apparently 
any client (for sure I tested on at least 1 Vista 64bit and 1 XP 32bit).

Also happens in the middle of transferring one file, so not necessarily 
at file change. The files are being pushed from the clients to the linux 
Server.

The gigabit switch between the machines was changed 2 times (the brands 
also were different) without results.

I was able to obtain apparently reliable nonstop transfer if I performed 
6 simultaneous transfers with Samba from the same client to the same 
server. OTOH with just 1 - 3 simultaneous transfers only all of them 
will eventually stall. Note that with 2 transfers the speed of each one 
is already smaller than the speed of a single transfer (approx 
40+40MB/sec vs 60MB/sec) however with 6 transfers it's obviously much 
smaller (approx 6x12MB/sec). The bug looks like some kind of a race 
condition to me.

On Samba another strange fact is that if there are multiple transfers 
(i.e. 2) from the same client to the same server (please note that in 
this case with Samba all transfers pass through the same TCP socket) the 
two transfers stall *independently* one to the other. First after a 
random time you see one stalling, and eventually after another random 
time also the other one stalls. This tells that the socket actually 
kinda works... I can even stop one stalled transfer from the client (the 
stop operation *works* and gets a reply from the Samba server: I see 
messages sniffing the Ethernet), and start it again and it would run, 
and the TCP socket is always the same when I restart the transfer.

I obtained apparently reliable transfers with Samba if I introduced rate 
limiting on our SMC 8024L2 gigabit switch . Even if the rate limiting 
was set so high (930Mbps) that the transfer speed was actually not 
influenced, the Samba transfer (1 single transfer, not multiple) 
apparently worked reliably. Maybe this helps with the race condition by 
separating packets better. The SFTP protocol hanged anyway though, even 
on rate limiting, however consider that SFTP from windows goes very slow 
at 15Mbps due to a problem of encryption performance of WinSCP, so that 
one is really way lower than the rate limit and its packets might not 
get separated.

The server is a linux Ubuntu 9.10 with kernel ubuntu 2.6.31-14-server . 
The ethernets are two integrated Intels (I tested both ethernet ports):
Ethernet controller: Intel Corporation 80003ES2LAN Gigabit Ethernet 
Controller (Copper) (rev 01)
the driver is kernel's e1000

This is the stack trace of server processes (Server side) during an SFTP 
stall:

root       327  [CUT] \_ sshd: myuser [priv]
1011       380  [CUT]     \_ sshd: myuser
1011       382  [CUT]         \_ /usr/lib/openssh/sftp-server

root@mystorage:/proc# cat /proc/327/stack   (this is sshd)
[<ffffffff814b428a>] unix_stream_data_wait+0xaa/0x110
[<ffffffff814b50cd>] unix_stream_recvmsg+0x36d/0x570
[<ffffffff81426399>] sock_aio_read+0x149/0x150
[<ffffffff8111e232>] do_sync_read+0xf2/0x130
[<ffffffff8111e8e1>] vfs_read+0x181/0x1a0
[<ffffffff8111edec>] sys_read+0x4c/0x80
[<ffffffff81011fc2>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

root@mystorage:/proc# cat /proc/380/stack   (this is the second sshd)
[<ffffffff8112e644>] poll_schedule_timeout+0x34/0x50
[<ffffffff8112ef4f>] do_select+0x58f/0x6b0
[<ffffffff8112f8b5>] core_sys_select+0x185/0x2b0
[<ffffffff8112fc32>] sys_select+0x42/0x110
[<ffffffff81011fc2>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

root@mystorage:/proc# cat /proc/382/stack (this is sftp-server)
[<ffffffff8112e644>] poll_schedule_timeout+0x34/0x50
[<ffffffff8112ef4f>] do_select+0x58f/0x6b0
[<ffffffff8112f8b5>] core_sys_select+0x185/0x2b0
[<ffffffff8112fc32>] sys_select+0x42/0x110
[<ffffffff81011fc2>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

so everything seems normal, it just seems the socket is waiting for data...

I am really puzzled because... I don't know how the Samba protocol 
works, but for SFTP which I believe is a simple protocol, I believe the 
client is just pushing raw bytes onto a simple TCP socket so it should 
keep doing that while it receives Acks. OTOH if it does not receive Acks 
the socket would disconnect. However in my case during a stall the 
socket stays Established (I checked at BOTH sides!) but the client stops 
pushing bytes to the server. (That's for a stall in the middle of a file 
on SFTP protocol, which *does* happen) How on earth can that be??  
(update: see tcpdump below, it might explain)

I am also thinking at a hardware problem. The server is running on a 
Tyan mainboard S5396WA2NRF and we had another problem with this computer 
(mobo?), apparently hardware related, with 3ware disk controllers, same 
problem as this guy also running another Tyan:
http://www.webhostingtalk.com/archive/index.php/t-449670.html
which I thought might be reconducible to a lost interrupt. Even on a 
lost interrupt I can't understand how to solve the Ack puzzle... this is 
not a TOE network card!

This is what I did try up to now (and didn't help):
   
Changed some Samba parameters trying various values (clearly not useful 
for SFTP btw). I ended up with a pretty common configuration, which 
anyway didn't help:
    socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=8192 
SO_SNDBUF=8192
    read raw = yes
    write raw = yes
    kernel oplocks = yes
    max xmit = 2048
    getwd cache = yes


Changed the following parameters in /proc/sys/net:
    1 -> 0 > ipv6/bindv6only (for Samba but it was bound already and I 
couldn't reboot. SFTP tests were done in IPv4 though)
    1 -> 0 > tcp_sack
    1 -> 0 > tcp_dsack
    0 -> 1 > tcp_low_latency
    2 -> 0 > tcp_frto
    cubic -> reno > tcp_congestion_control
    3 -> 6 > tcp_retries1
    3 -> 10 > tcp_tso_win_divisor
    1 -> 0 > tcp_slow_start_after_idle


Then I disabled the following offloads using ethtool:
    rx-checksumming on --> off
    tx-checksumming on --> off
    scatter-gather on --> off
    tcp-segmentation-offload: on --> off
    generic-segmentation-offload: on --> off

Nothing helped.


This is the SFTP socket when it's running (Server side):
# cat /proc/net/tcp
   2: 0F12A8C0:0016 2612A8C0:C0C6 01 00000000:00000000 02:000AB698 
00000000     0        0 267816 4 ffff88084b1e6180 24 4 1 11 -1

Later on, when it has been stuck for a while:
# cat /proc/net/tcp
   2: 0F12A8C0:0016 2612A8C0:C0C6 01 00000000:00000000 02:0002AC6B 
00000000     0        0 267816 2 ffff88084b1e6180 27 4 1 21 -1
(numbers reference: 
http://www.mjmwired.net/kernel/Documentation/networking/proc_net_tcp.txt )

as you can see from the last values, the timeout and window have 
enlarged a bit, but nothing dramatic. Apparently they are very similar.

This is another SFTP stall after I disabled the offloading via ethtool: 
(different transfer, different socket from above)
  2: 0F12A8C0:0016 2512A8C0:09BC 01 00000000:00000000 02:000602F4 
00000000     0        0 5301100 2 ffff88084ac02080 28 4 0 13 -1
so the values are similar again, apart the ack.pingpong which has become 
0   (something to do with offloading?)


This night I decided to actually tcpdump some traffic at the server 
side. This dump has a chance of being incorrect/misleading because the 
client I could use was already transferring other stuff to the server 
via Samba. I used SFTP protocol for this test but due to the 
simultaneous Samba transfer I could not obtain a long SFTP hangup. The 
longest hangup I obtained is 1 minute. I hope this is really a 
manifestation of the bug in question, and not a simple temporary 
starvation at server side.

Here is the relevant excerpt:
00:54:36.303031 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 12309129:12309229, ack 997119732, win 65535, length 100
00:54:36.303216 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 997119732:997120040, ack 12309229, win 64871, length 308
00:54:36.303450 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 12309229:12309297, ack 997120040, win 65535, length 68
00:54:36.303566 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 997120040:997120228, ack 12309297, win 64803, length 188
00:54:36.303645 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 12309297:12309365, ack 997120228, win 65535, length 68
00:54:36.304414 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 997120228:997120432, ack 12309365, win 64735, length 204
00:54:36.345583 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
997120432, win 65535, length 0       *** PROBLEM IS HERE ***
00:55:27.171687 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 12309365:12309425, ack 997120432, win 65535, length 60
00:55:27.342682 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 997120432:997120944, ack 12309425, win 64675, length 512
00:55:27.342726 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
997120944, win 65535, length 0
00:55:27.342775 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [.], seq 
997120944:997122404, ack 12309425, win 64675, length 1460
00:55:27.342787 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
997122404, win 65535, length 0
00:55:27.342792 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 997122404:997122612, ack 12309425, win 64675, length 208
00:55:27.342795 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
997122612, win 65535, length 0

It seems to me the TCP stack at the Server returns an ack to the client 
but waits 1 minutes before being able to give the further 60 bytes to 
the client (these are application-generated bytes, right?) which are 
probably needed at client-side for the functioning of the SFTP protocol.
I suspect the SFTP-server application receives the last client data just 
at the end of the minute of delay (at 00:55:27.1something)
Probably if the dump was made without concomitant Samba activity, the 
sftp-server application would have never received such last client bytes 
and that's why the hangup lasts forever.
However the TCP socket remains established because the TCP stack works 
and acks are sent properly
Could this be a good interpretation of the bug?

I don't know what are those 60 bytes though, can you confirm is it a 
part of the SFTP or SSH protocol?

I observed other similar micro-hangups:
...
00:50:59.210115 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
3346661444, win 65535, length 0
00:51:14.137978 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 7757313:7757457, ack 3346661444, win 65535, length 144
...
00:52:02.495785 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 8612969:8613037, ack 3711382248, win 65535, length 68
00:52:02.507752 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 3711382248:3711382452, ack 8613037, win 65399, length 204
00:52:02.545585 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
3711382452, win 65535, length 0
00:52:14.568489 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 8613037:8613097, ack 3711382452, win 65535, length 60
00:52:14.572162 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [P.], 
seq 3711382452:3711382964, ack 8613097, win 65339, length 512
00:52:14.572184 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
3711382964, win 65535, length 0
00:52:14.572312 IP 192.168.18.37.3418 > 192.168.18.15.22: Flags [.], seq 
3711382964:3711384424, ack 8613097, win 65339, length 1460
...
00:55:30.464957 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
1040635920, win 65535, length 0
00:55:32.230205 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 12410749:12410809, ack 1040635920, win 65535, length 60
...
00:55:54.404027 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
1362376840, win 65535, length 0
00:56:08.349224 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 13157437:13157497, ack 1362376840, win 65535, length 60
...
00:56:28.494333 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [.], ack 
1424904580, win 65535, length 0
00:56:31.450352 IP 192.168.18.15.22 > 192.168.18.37.3418: Flags [P.], 
seq 13307333:13307393, ack 1424904580, win 65535, length 60

Update: actually I just found a disk performance problem at Server side 
so that the disks couldn't go faster than 70MB/sec (stripe_cache_size 
was too low and readahead was too low), and I'm thinking if this could 
be the reason for indeed triggering the bug: if there was a starvation 
of the TCP/IP stack or network card driver at the wrong time (because 
i.e. the CPUs are doing something else like accessing the disks), could 
that prevent the 60-bytes packet from ever being transmitted...? (in 
case of no other incoming ethernet packets which can give the TCPIP or 
e1000 driver a second chance to run)

Thanks for your help
Asdo
