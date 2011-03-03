From: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Subject: Bad performance when CUBIC HyStart enabled
Date: Thu, 3 Mar 2011 15:22:29 +0100
Message-ID: <20110303142229.GA9262@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sangtae Ha <sha2@ncsu.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:33692 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758234Ab1CCOqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 09:46:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm experiencing bad performance transferring data over a large BDP
network with CUBIC when HyStart is enabled. Disabling HyStart fixes the
problem.

Test setup:
I'm transfering a 2-GB file between two machines using netcat. On both
machines, /dev/shm is used to store the data.
On the sending side, I use:
/dev/shm# while true; do dd if=3Dfoo bs=3D10M | nc -l -p 2222 -q 0; don=
e
On the receiving side, I use:
/dev/shm# /usr/bin/time nc 131.254.203.6 2222 > foo
Both machines are on Gigabit ethernet networks, and the RTT between the=
m
is 11.3ms.
The default sysctl values are used.
I use nload -i 1000000 -o 1000000 -u m eth0 to visualize the transfer
rate.

With a 2.6.26 kernel, everything is fine. The bandwidth quickly gets to
~940 Mbps, and I get the following in nload:
      ..................................
     .##################################
     ###################################
     ###################################
     ###################################
     ####################################
     ####################################
     ####################################
     ####################################
     ####################################
     ####################################
     ####################################
     ####################################
     ####################################
The transfer time is 18.2s, which is reasonable for a 2-GB file.

With a 2.6.32 kernel (Debian's) or with a 2.6.37 kernel (on the sending
side only), with the default HyStart parameters, I get the following:
                           ..........................
                          |##########################.
                         |############################
                        |#############################
                       |##############################
                      |###############################
                    .#################################
                   |##################################|=20
                 |#####################################=20
            ..||#######################################=20
    ....|##############################################=20
 .#####################################################=20
The transfer time is 26.8s. (There's one character every 0.5s on the
graph above)

Disabling hystart on the sending machine with:
echo 0 > /sys/module/tcp_cubic/parameters/hystart
=46ixes the problem.

It seems that waiting for some time (or rebooting) fixes the problem fo=
r
some time, so I'm suspecting that the problem is caused by a cache of
some sort. However, doing:
echo 1 > /proc/sys/net/ipv4/route/flush
doesn't fix the problem.

Ideas? I could arrange to give access to the testbed if needed.
(https://www.grid5000.fr/)
--=20
| Lucas Nussbaum             MCF Universit=E9 Nancy 2 |
| lucas.nussbaum@loria.fr         LORIA / AlGorille |
| http://www.loria.fr/~lnussbau/  +33 3 54 95 86 19 |
