From: Tomasz Grabowski <cadence@rubycon.man.szczecin.pl>
Subject: Security bug in 2.2 kernel series
Date: Mon, 12 Jan 2004 21:24:01 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401122035530.19102@rubycon.man.szczecin.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alan.Cox@linux.org, netdev@oss.sgi.com, jmorris@intercode.com.au,
        cert@cert.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul.Russell@rustcorp.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello.

I found security bug in TCP/IP stack implementation in Linux 2.2. kernel
series.


Short description:
Machine A is sending SYN packet to machine B, which is running linux
kernel version 2.2. Machine B is responding with SYN+ACK packet and is
waiting for ACK packet from machine A. So far everything is good. Now,
machine A is sending another SYN packet with same source and destination
address and same source and destination port. Machine B should respond
with RST packet and drop that connection. Unfortunatelly, kernel 2.2 is
accepting that second SYN packet, setting up another socket for it in
SYN_RECV state and responding with another SYN+ACK packet which differ
from the original one only by another Initial Sequence Number. Now,
machine A can send many such SYN packets, and machine B will set up
sockets for every one of them.
My first thought was that it could be used for birthday paradox attacks
for ISN guessing, but it turned out that only the first generated sequence
number (i.e. the first SYN+ACK generated in reply to first SYN packet) is
the right one. If you will send ACK packet with sequence number generated
in other SYN+ACK packets it will be dropped anyway. So, it can't be used
to birthday paradox attacks.
But it can be used to carry out DoS attacks.

Attack scenario:
A is machine with mail service on port 25, running kernel 2.2
B is machine which is trying to send mail to machine A.

Attacker is trying to prevent machine B from sending mail to machine A.

If attacker will be able to predict the source port which machine B will
use to connect to machine's A mail service, he can set up a 'trap' by
sending SYN packet(s) to machine A port 25 with spoofed source host
address and port number of machine B. Predicting source port number isn't
hard in many environments as it is mostly a number from fixed range of
well-known ports. The impact is much greater in applications that are
connecting from particular (e.g. priviledged) source ports.

I'm currently in the middle of developing convenient exploit for this
vulnerability. It's working well in my laboratory but I will need to make
it more robust so it will be possible to check for that vulnerabilty in
production servers. I want to check more services and more environments to
assure that my exploit will work well in different enviroments.

For now, you can very easilly reconstruct this kernel behavior with
'hping':

hping 10.20.20.20 -p 80 -s 20000 -a 10.10.10.10 -S -c 1
[do it few times]

10.20.20.20:~# netstat -an|grep 10.10.10.10
tcp        0      0 10.20.20.20:80          10.10.10.10:20000 SYN_RECV
tcp        0      0 10.20.20.20:80          10.10.10.10:20000 SYN_RECV
tcp        0      0 10.20.20.20:80          10.10.10.10:20000 SYN_RECV
tcp        0      0 10.20.20.20:80          10.10.10.10:20000 SYN_RECV


I think that the patch is very easy, althought I'm not kernel developer
and I'm not even trying to make one myself. Could you tell me when you
will be able to provide a patch? Of course I will not let the exploit leak
out until you will provide fully tested patch.

If you have any questions or comments regarding this bug, do not hesitate
to contact me.


Best regards,

-- 
Tomasz Grabowski
Technical University of Szczecin,	    +48 (91)4494234
Academic Centre of Computer Science	www.man.szczecin.pl
