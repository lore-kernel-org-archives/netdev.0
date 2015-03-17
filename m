From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 94991] New: TCP bug creates additional RTO in very
 specific condition
Date: Tue, 17 Mar 2015 08:33:33 -0700
Message-ID: <20150317083333.65b7af40@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34570 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460AbbCQPde convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 11:33:34 -0400
Received: by pacwe9 with SMTP id we9so12936276pac.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 08:33:33 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id dt10sm22989725pdb.82.2015.03.17.08.33.32
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 08:33:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 17 Mar 2015 13:20:34 +0000
=46rom: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla=
=2Ekernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 94991] New: TCP bug creates additional RTO in very specif=
ic condition


https://bugzilla.kernel.org/show_bug.cgi?id=3D94991

            Bug ID: 94991
           Summary: TCP bug creates additional RTO in very specific
                    condition
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32-504.3.3.el6.x86_64
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: matiasb@gmail.com
        Regression: No

Created attachment 170931
  --> https://bugzilla.kernel.org/attachment.cgi?id=3D170931&action=3De=
dit
server tcpdump showing the bug

Hi all,

We found an unexpected behavior in the applications which we are using =
that
appears to be a bug in the TCP algorithm. Following tcpdumps we detecte=
d that a
second unnecessary retransmission timeout (RTO) occurs after a first va=
lid RTO.
This occurs only in a very particular situation: when there are 2 packe=
ts
pending to be sent at the moment the first retransmission occurs (and a=
lso in
the context of our application which operates in a very low latency net=
work,
and which its only traffic is receiving a single request message and se=
nding a
~12KB response). This situation occurs very often in our context and be=
cause
the application operates at very low latency a RTO impacts severely the
performance.
More details of the application communication and tcpdumps with the bug
explanation is copied below.

Is this a proper bug or is there something we are missing expected TCP
behavoir? Also, is there is this a known way to avoid this unexpected
behaviour?

Thank you very much,
Regards,
Matias

Environment
OS: SLC 6
 $ uname -a
Linux <pcName> 2.6.32-504.3.3.el6.x86_64 #1 SMP Wed Dec 17 09:22:39 CET=
 2014
x86_64 x86_64 x86_64 GNU/Linux

TCP configuration: full configuration from  /proc/sys/net/ipv4/* pasted=
 at the
bottom.
tcp_base_mss=3D512                          =20
tcp_congestion_control=3Dcubic  =20
tcp_sack=3D1


Application communication description:  We are using 2 applications whi=
ch
communicate using TCP: a client and around 200 server application.  The=
 client
sends a request message of 188B (including headers) to all servers and =
waits
for a response of all of them. The client does not send any other messa=
ge until
the response of all servers is received. Each server upon receiving the
request, it sends a 12KB response (which is obviously splitted into sev=
eral TCP
packets).  Because there are 200 servers responding at almost the same =
moment
(with a total of ~2.4MB) some buffers in the network may overflow gener=
ating
drops and retransmissions.
When there are no drops (thanks to control application that limits the =
requests
sent) the latency to receive all messages from all servers is ~20ms. If=
 there
is a drop of one or more TCP fragments then the latency goes to near ~2=
00ms
(this is because of the minimum RTO of 200ms hardcoded in the kernel). =
Even if
this is 10 times higher it is more or less under acceptable for the
application. The bug creates a second consecutive retransmission so the=
 latency
when this occurs goes to 600ms (200ms of the first RTO + 400ms of the s=
econd
unexpected RTO), which is out of the limits that the application can ha=
ndle (60
times higher).

Bug detailed description:
The unexpected behavior appears in the server applications when TCP nee=
ds to
retransmit drops packets. It appears in all server applications at a qu=
ite a
high frequency.
The bug appears only when the server detected a drop (by a RTO after 20=
0ms) and
at that moment it is still pending to receive the ACK for 2 packets. In=
 that
case, after 200ms of sending all packets, the RTO triggers the retransm=
ission
of the first packet, then the ACK for that packet is received but the s=
econd
packet is not retransmitted at that moment. After another 400ms another=
 RTO is
triggered and that second packet is retransmitted and ACKed. To our
understanding this second retransmission should not occur. The expected
behaviour is that the second packet is retransmitted right after receiv=
ing the
ACK for the first retransmitted packet.
Also this unexpected second RTO occurs only if there are 2 pending pack=
ets at
the moment of the first RTO.  If  there is one packet to retransmit for=
 more
than 2, the behaviour is as expected, all packets are retransmitted and=
 ACKed
after the first RTO (there is no second RTO).=20

Below the explanation and a section of a tcpdump recorded in one of the=
 server
applications showing the unexpected behaviour.=20

=46rame #170:  request is received (at T 0)
=46rames #171-#173: response is sent splitted into several TCP packets.=
 From
seq=3D204273 to seq=3D216289.
=46rame #171 and #172 are recorded by tcpdump as a single packet but is=
 probably
several real packets as the MSS is 1460 bytes and it shows a lenght hig=
her than
that (this is probably caused because NICs support segmentation offload=
s, which
means, that the NIC joins the segments together and pushes it to the ho=
st=E2=80=99s TCP
stack a single segment. This is why tcpdump sees it as a segment of hig=
her
length).
=46rames #173-#177: ACKs for some of the sent packets is received. Last=
 seq
acknowledged is seq=3D442797 (there is still 1796 bytes to be sent, whi=
ch is 2
TCP packets).
=46rame #178: At T 207ms a packet is retransmitted. This is the first
retransmission, which makes total sense as the ACKs for 2 packets were =
not
received after 200ms. Because of the RTO the TCP internal state should =
be
updated to duplicate the RTO (so it should be 400ms now). Also the CWND=
 should
be reduced to 1.
=46rame #179: ACK for the retransmitted packet is received.=20
The internal state of TCP should be update to duplicate the CWND becaus=
e of
slow start (so should be set now to 2). RTO is not updated because calc=
ulation
of RTO is based only in packets which were not retransmitted.
At this point we would expect that the pending packet should be retrans=
mitted,
but this does not occur. After receiving an ACK the CWDN should allow m=
ore
packets to be sent, but there is no data sent by the server (and conseq=
uently
it receives nothing).
=46rame #180: at T 613ms (aprox ~400ms after the last received ACK) the=
 last
packet is retransmitted.
This is what creates a 600ms latency which is 60 times the expected and=
 6 times
higher if the bug would not be present.
=46rame #181: ACK for the last packet is received.
=46rame #182: a new request is received..


No.  Time      Source    Destination   Protocol RTO        Length Info
170 *REF*       DCM          ROS         TCP            118    47997 > =
41418
[PSH, ACK] Seq=3D1089 Ack=3D204273 Win=3D10757 Len=3D64
171 0.000073    ROS         DCM          TCP            5894   41418 > =
47997
[ACK] Seq=3D204273 Ack=3D1153 Win=3D58 Len=3D5840
172 0.000080    ROS         DCM          TCP            5894   41418 > =
47997
[ACK] Seq=3D210113 Ack=3D1153 Win=3D58 Len=3D5840
173 0.000083    ROS         DCM          TCP            390    41418 > =
47997
[PSH, ACK] Seq=3D215953 Ack=3D1153 Win=3D58 Len=3D336[Packet size limit=
ed during
capture]
174 0.003901    DCM          ROS         TCP           60     47997 > 4=
1418
[ACK] Seq=3D1153 Ack=3D207193 Win=3D10757 Len=3D0
175 0.004270    DCM          ROS         TCP            60     47997 > =
41418
[ACK] Seq=3D1153 Ack=3D211573 Win=3D10768 Len=3D0
176 0.004649    DCM          ROS         TCP            60     47997 > =
41418
[ACK] Seq=3D1153 Ack=3D213033 Win=3D10768 Len=3D0
177 0.004835    DCM          ROS         TCP            66     [TCP Dup=
 ACK
176#1] 47997 > 41418 [ACK] Seq=3D1153 Ack=3D213033 Win=3D10768 Len=3D0 =
SLE=3D214493
SRE=3D215953
178 0.207472    ROS         DCM          TCP    0.207389000  1514   [TC=
P
Retransmission] 41418 > 47997 [ACK] Seq=3D213033 Ack=3D1153 Win=3D58 Le=
n=3D1460
179 0.207609    DCM          ROS         TCP            60     47997 > =
41418
[ACK] Seq=3D1153 Ack=3D215953 Win=3D10768 Len=3D0
180 0.613472    ROS         DCM          TCP    0.613389000  390    [TC=
P
Retransmission] 41418 > 47997 [PSH, ACK] Seq=3D215953 Ack=3D1153 Win=3D=
58
Len=3D336[Packet size limited during capture]
181 0.613622    DCM          ROS         TCP            60     47997 > =
41418
[ACK] Seq=3D1153 Ack=3D216289 Win=3D10768 Len=3D0
182 0.615189    DCM          ROS         TCP            118    47997 > =
41418
[PSH, ACK] Seq=3D1153 Ack=3D216289 Win=3D10768 Len=3D64






=46ull TCP configuration: for f in /proc/sys/net/ipv4/* ;do confName=3D=
$(basename
"$f") ; echo -n "$confName=3D"  >> /logs/tpu_TCP_config.txt ; cat "$f" =
>>
/logs/tpu_TCP_config.txt ;done

cipso_cache_bucket_size=3D10
cipso_cache_enable=3D1     =20
cipso_rbm_optfmt=3D0       =20
cipso_rbm_strictvalid=3D1  =20
icmp_echo_ignore_all=3D0
icmp_echo_ignore_broadcasts=3D1
icmp_errors_use_inbound_ifaddr=3D0
icmp_ignore_bogus_error_responses=3D1
icmp_ratelimit=3D1000               =20
icmp_ratemask=3D6168                =20
igmp_max_memberships=3D20           =20
igmp_max_msf=3D10                   =20
inet_peer_gc_maxtime=3D120          =20
inet_peer_gc_mintime=3D10           =20
inet_peer_maxttl=3D600              =20
inet_peer_minttl=3D120              =20
inet_peer_threshold=3D65664         =20
ip_default_ttl=3D64                 =20
ip_dynaddr=3D0                      =20
ip_forward=3D0                      =20
ipfrag_high_thresh=3D262144         =20
ipfrag_low_thresh=3D196608          =20
ipfrag_max_dist=3D64                =20
ipfrag_secret_interval=3D600        =20
ipfrag_time=3D30                    =20
ip_local_port_range=3D32768       61000
ip_local_reserved_ports=3D            =20
ip_nonlocal_bind=3D0                  =20
ip_no_pmtu_disc=3D0                   =20
ping_group_range=3D1        0   =20
rt_cache_rebuild_count=3D4      =20
tcp_abc=3D0                           =20
tcp_abort_on_overflow=3D0             =20
tcp_adv_win_scale=3D2                 =20
tcp_allowed_congestion_control=3Dcubic reno
tcp_app_win=3D31                          =20
tcp_available_congestion_control=3Dcubic reno
tcp_base_mss=3D512                          =20
tcp_challenge_ack_limit=3D100               =20
tcp_congestion_control=3Dcubic              =20
tcp_dma_copybreak=3D262144                  =20
tcp_dsack=3D1                               =20
tcp_ecn=3D2                                 =20
tcp_fack=3D1                                =20
tcp_fin_timeout=3D60                        =20
tcp_frto=3D2                                =20
tcp_frto_response=3D0                       =20
tcp_keepalive_intvl=3D75                    =20
tcp_keepalive_probes=3D9                    =20
tcp_keepalive_time=3D7200                   =20
tcp_limit_output_bytes=3D131072             =20
tcp_low_latency=3D0                         =20
tcp_max_orphans=3D262144                    =20
tcp_max_ssthresh=3D0                        =20
tcp_max_syn_backlog=3D2048                  =20
tcp_max_tw_buckets=3D262144                 =20
tcp_mem=3D2316864 3089152 4633728           =20
tcp_min_tso_segs=3D2                        =20
tcp_moderate_rcvbuf=3D1                     =20
tcp_mtu_probing=3D0                         =20
tcp_no_metrics_save=3D0                     =20
tcp_orphan_retries=3D0                      =20
tcp_reordering=3D3                          =20
tcp_retrans_collapse=3D1                    =20
tcp_retries1=3D3                            =20
tcp_retries2=3D15                           =20
tcp_rfc1337=3D0                             =20
tcp_rmem=3D4096   87380   4194304
tcp_sack=3D1
tcp_slow_start_after_idle=3D0
tcp_stdurg=3D0
tcp_synack_retries=3D5
tcp_syncookies=3D1
tcp_syn_retries=3D5
tcp_thin_dupack=3D0
tcp_thin_linear_timeouts=3D0
tcp_timestamps=3D0
tcp_tso_win_divisor=3D3
tcp_tw_recycle=3D0
tcp_tw_reuse=3D0
tcp_window_scaling=3D1
tcp_wmem=3D4096   65536   4194304
tcp_workaround_signed_windows=3D0
udp_mem=3D2316864 3089152 4633728
udp_rmem_min=3D4096
udp_wmem_min=3D4096
xfrm4_gc_thresh=3D4194304

--=20
You are receiving this mail because:
You are the assignee for the bug.
