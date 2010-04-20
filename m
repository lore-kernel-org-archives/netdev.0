From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of
	outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 03:17:08 +0500
Message-ID: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:53919 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab0DTWRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 18:17:10 -0400
Received: by bwz25 with SMTP id 25so7386777bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 15:17:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[1.] Large amount of outgoing tcp connections fail to bind properly to
their ip/ports

[2.] Full description of the problem/report:

I'm trying to establish huge amount of outgoing tcp connections (over
several 100000-s) on a single machine. I need to test load a server,
which could process that amount of connections :)

The number of connections which are possible to establish from single
ip is regulated by
net.ipv4.ip_local_port_range = 32768    61000, which gives 28232 connections.

Good. I expect that each socket is identified on a local side as
unique pair of local_ip:local_port .
Thus I've added some more IP addresses (say 10) to the machine
(aliases to the same network interface).
I expect to be able to establish 10 times more connections than before
(I know about file descriptor limits, system limit of total number of
file descriptors and  so on - which are tuned to high values already).

And the fun part begins -
I have 28232 on a first source IP (all in established state, say
10.0.0.10) and now I'm trying to establish one more connection with
nc, specifying 10.0.0.11 as a source IP -- and getting "unable to bind
error"

Notes about example;
10.0.0.1:8192 is a server which just accepts a connections and listens
forever on them. It's in erlang and it can handle great loads -- so
there is not problems on that side.
Using the same script I was able to establish more than 20.000
connections without any problems (having a standard local port range
set)


To make experiment easily reproducible I've done the following things:

Decrease number of local ports available to 1001 -
net.ipv4.ip_local_port_range = 60000    61000

I have script like this (writing from memory)

#!/bin/sh

I=0

IP=10.0.0.10

# connection stats before run
netstat -n | grep ESTABLISHED | fgrep "$IP" | wc -l

while [ $I -le 1000 ]; do

# run nc in background, supress any output
nc -s $IP 10.0.0.1 8192 > /dev/null 2>&1 &

I=$(($I + 1))

done

# connection stats after run
netstat -n | grep ESTABLISHED | fgrep "$IP" | wc -l


EVEN on the first run I get only 990 successful connections! something
fails, strange ....

nc 10.0.0.1 8192 fails with error "unable to bind" and establishes
connection only from 5-10 try.

Ook, well, run this script again, get all possible 1001 connections
and than change source IP to 10.0.0.11

If you run in several times you will get the following numbers of
established connections about each run (for given source IP)
~650, ~870, 950,980,990,995,995, 1000 and several runs to get 1001.

Then if you change IP to the next available and run it again - you
will get practically the same numbers and this continues for 3-th,
4th, 5-th and other IP's.


As a programmer, I feel that there is some hash table for
local_ip:local_port pairs in the kernel (may be also incorporating
PID), which has a collisions and
in case of collision it just fails to reserve/bind this pair for the
socket.  I hope I'm right, but I've failed to find where the
allocation is done :)
In case if PID does not change (i've tried to run tests from primitive
client in erlang as well -- you get much more worse picture and
getting new socket becomes just impossible).

I think that even in case if there is one port available for that IP
-- it should be possible to bind (even if the kernel should do the
full scan on local port range to find that unused port).


I would be grateful for hints where to look in the source -- may be I
can produce some working patches for it.


[3.] Keywords (i.e., modules, networking, kernel):
does not matter, i think.

[4.] Kernel version (from /proc/version):
Ubuntu Karmic Koala on amd64 with latest shipped kernel.
Linux version 2.6.31-21-generic (buildd@yellow) (gcc version 4.4.1
(Ubuntu 4.4.1-4ubuntu9) ) #59-Ubuntu SMP Wed Mar 24 07:28:27 UTC 2010


[5.] Output of Oops.. message (if applicable) with symbolic information
    resolved (see Documentation/oops-tracing.txt)
n/a

[6.] A small shell script or example program which triggers the
    problem (if possible)
[7.] Environment


Thanks in advance,
Gaspar



--
Gaspar Chilingarov

tel +37493 419763 (mobile - leave voice mail message)
icq 63174784
skype://gasparch
e mailto:nm@web.am mailto:gasparch@gmail.com
w http://gasparchilingarov.com/
