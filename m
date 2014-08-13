From: Vasily Averin <vvs@parallels.com>
Subject: [PATCH 0/2] cbq: incorrectly low bandwidth blocks limited traffic
Date: Wed, 13 Aug 2014 16:38:09 +0400
Message-ID: <53EB5C31.7010602@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070807000604010902040002"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:26492 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbaHMMjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 08:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070807000604010902040002
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Mainstream commit f0f6ee1f70c4eaab9d52cf7d255df4bd89f8d1c2 have side effect:
if cbq bandwidth setting is less than real interface throughput
non-limited traffic can delay limited traffic for a very long time.

This happen (again) because of q->now changes incorrectly in cbq_dequeue():
in described scenario L2T is much greater than real time delay,
and q->now gets an extra boost for each transmitted packet.

To compensate this boost we did not changed q->now until it will be
synchronized with real time. Unfortunately it does not work in described
scenario: boost accumulated by non-limited traffic blocks processing
of limited traffic.

Below you can found an example of this problem.

To fix the problem I propose the following path set:

Vasily Averin (2):
  cbq: incorrectly low bandwidth setting blocks limited traffic
  cbq: now_rt removal

 net/sched/sch_cbq.c |   48 ++++++++++++++----------------------------------
 1 files changed, 14 insertions(+), 34 deletions(-)

First patch prevents incorrect updates q->now in cbq_dequeue(),
now it just saves real time on each function call.
q_now change required for cbg_update() was compensated inside this function.

Second patch removes q->now_rt because now it is identical to q->now.

My testing confirms that these patches fixes the problem,
and do not affect 

Thank you,
	Vasily Averin

Node gigabit link, 100Mbit bandwidth in cbq, and 70 Mbit limit for some traffic

# tc qdisc del dev eth0 root
# tc qdisc add dev eth0 root handle 1: cbq avpkt 64kb bandwidth 100Mbit
# tc class add dev eth0 parent 1: classid 1:1 cbq rate 70Mbit bounded allot 64kb
# tc filter add dev eth0 parent 1: protocol ip u32 match ip dst 10.30.3.116 flowid 1:1 

Initially shaper works correctly

# netperf -H 10.30.3.116 -l5
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.30.3.116 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    5.08       66.31

... then node generates some non-limited traffic...

# netperf -H ANOTHER_IP -l5
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to ANOTHER_IP () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    5.02      818.12

... and it blocks limited traffic

# netperf -H 10.30.3.116 -l5
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.30.3.116 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    9.00        0.10

Ping on neighbor console shows that traffic is not dropped but delayed

64 bytes from 10.30.3.116: icmp_seq=17 ttl=64 time=0.131 ms
64 bytes from 10.30.3.116: icmp_seq=18 ttl=64 time=0.161 ms
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
64 bytes from 10.30.3.116: icmp_seq=19 ttl=64 time=37568 ms
64 bytes from 10.30.3.116: icmp_seq=20 ttl=64 time=36568 ms
64 bytes from 10.30.3.116: icmp_seq=21 ttl=64 time=35568 ms
64 bytes from 10.30.3.116: icmp_seq=22 ttl=64 time=34568 ms
64 bytes from 10.30.3.116: icmp_seq=23 ttl=64 time=33568 ms
64 bytes from 10.30.3.116: icmp_seq=24 ttl=64 time=32568 ms
64 bytes from 10.30.3.116: icmp_seq=25 ttl=64 time=31569 ms
64 bytes from 10.30.3.116: icmp_seq=26 ttl=64 time=30569 ms
64 bytes from 10.30.3.116: icmp_seq=27 ttl=64 time=29569 ms
64 bytes from 10.30.3.116: icmp_seq=28 ttl=64 time=28569 ms
64 bytes from 10.30.3.116: icmp_seq=29 ttl=64 time=27570 ms
64 bytes from 10.30.3.116: icmp_seq=30 ttl=64 time=26570 ms
64 bytes from 10.30.3.116: icmp_seq=38 ttl=64 time=0.187 ms

tc -s -d class ls dev eth0 output taken while limited traffic was blocked is attached.

--------------070807000604010902040002
Content-Type: text/plain; charset=us-ascii;
 name="tc-cbq-stat.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tc-cbq-stat.txt"

V2VkIEF1ZyAxMyAxNToyOToyMCBNU0QgMjAxNApjbGFzcyBjYnEgMTogcm9vdCByYXRlIDEw
MDAwMEtiaXQgY2VsbCA1MTJiIChib3VuZGVkLGlzb2xhdGVkKSBwcmlvIG5vLXRyYW5zbWl0
Lzggd2VpZ2h0IDEwMDAwMEtiaXQgYWxsb3QgMTUxNGIgCmxldmVsIDEgZXdtYSA1IGF2cGt0
IDY1NTM2YiBtYXhpZGxlIDE2M3VzIAogU2VudCA1Mzc2MTEwODMgYnl0ZXMgODA1OCBwa3Qg
KGRyb3BwZWQgMCwgb3ZlcmxpbWl0cyAwIHJlcXVldWVzIDApIAogYmFja2xvZyAwYiAwcCBy
ZXF1ZXVlcyAwIAogIGJvcnJvd2VkIDAgb3ZlcmFjdGlvbnMgMCBhdmdpZGxlIDQ2MjQ1IHVu
ZGVydGltZSAwCmNsYXNzIGNicSAxOjEgcGFyZW50IDE6IHJhdGUgNzAwMDBLYml0IGNlbGwg
NTEyYiAoYm91bmRlZCkgcHJpbyBuby10cmFuc21pdC84IGFsbG90IDY1NTM2YiAKbGV2ZWwg
MCBld21hIDUgYXZwa3QgNjU1MzZiIG1heGlkbGUgMTYzdXMgCiBTZW50IDEyMTM5NiBieXRl
cyAyMyBwa3QgKGRyb3BwZWQgMCwgb3ZlcmxpbWl0cyAxMDE0NyByZXF1ZXVlcyAwKSAKIGJh
Y2tsb2cgMGIgNnAgcmVxdWV1ZXMgMCAKICBib3Jyb3dlZCAwIG92ZXJhY3Rpb25zIDEgYXZn
aWRsZSAtMjAzMSB1bmRlcnRpbWUgMzg3NQpXZWQgQXVnIDEzIDE1OjI5OjIyIE1TRCAyMDE0
CmNsYXNzIGNicSAxOiByb290IHJhdGUgMTAwMDAwS2JpdCBjZWxsIDUxMmIgKGJvdW5kZWQs
aXNvbGF0ZWQpIHByaW8gbm8tdHJhbnNtaXQvOCB3ZWlnaHQgMTAwMDAwS2JpdCBhbGxvdCAx
NTE0YiAKbGV2ZWwgMSBld21hIDUgYXZwa3QgNjU1MzZiIG1heGlkbGUgMTYzdXMgCiBTZW50
IDUzNzYxMTQ4OSBieXRlcyA4MDYxIHBrdCAoZHJvcHBlZCAwLCBvdmVybGltaXRzIDAgcmVx
dWV1ZXMgMCkgCiBiYWNrbG9nIDBiIDBwIHJlcXVldWVzIDAgCiAgYm9ycm93ZWQgMCBvdmVy
YWN0aW9ucyAwIGF2Z2lkbGUgNDIwNDQgdW5kZXJ0aW1lIDAKY2xhc3MgY2JxIDE6MSBwYXJl
bnQgMTogcmF0ZSA3MDAwMEtiaXQgY2VsbCA1MTJiIChib3VuZGVkKSBwcmlvIG5vLXRyYW5z
bWl0LzggYWxsb3QgNjU1MzZiIApsZXZlbCAwIGV3bWEgNSBhdnBrdCA2NTUzNmIgbWF4aWRs
ZSAxNjN1cyAKIFNlbnQgMTIxMzk2IGJ5dGVzIDIzIHBrdCAoZHJvcHBlZCAwLCBvdmVybGlt
aXRzIDIxNzExIHJlcXVldWVzIDApIAogYmFja2xvZyAwYiA3cCByZXF1ZXVlcyAwIAogIGJv
cnJvd2VkIDAgb3ZlcmFjdGlvbnMgMSBhdmdpZGxlIC0yMDMxIHVuZGVydGltZSAyMDAwCldl
ZCBBdWcgMTMgMTU6Mjk6MjQgTVNEIDIwMTQKY2xhc3MgY2JxIDE6IHJvb3QgcmF0ZSAxMDAw
MDBLYml0IGNlbGwgNTEyYiAoYm91bmRlZCxpc29sYXRlZCkgcHJpbyBuby10cmFuc21pdC84
IHdlaWdodCAxMDAwMDBLYml0IGFsbG90IDE1MTRiIApsZXZlbCAxIGV3bWEgNSBhdnBrdCA2
NTUzNmIgbWF4aWRsZSAxNjN1cyAKIFNlbnQgNTM3NjExODk1IGJ5dGVzIDgwNjQgcGt0IChk
cm9wcGVkIDAsIG92ZXJsaW1pdHMgMCByZXF1ZXVlcyAwKSAKIGJhY2tsb2cgMGIgMHAgcmVx
dWV1ZXMgMCAKICBib3Jyb3dlZCAwIG92ZXJhY3Rpb25zIDAgYXZnaWRsZSAzODIyNiB1bmRl
cnRpbWUgMApjbGFzcyBjYnEgMToxIHBhcmVudCAxOiByYXRlIDcwMDAwS2JpdCBjZWxsIDUx
MmIgKGJvdW5kZWQpIHByaW8gbm8tdHJhbnNtaXQvOCBhbGxvdCA2NTUzNmIgCmxldmVsIDAg
ZXdtYSA1IGF2cGt0IDY1NTM2YiBtYXhpZGxlIDE2M3VzIAogU2VudCAxMjEzOTYgYnl0ZXMg
MjMgcGt0IChkcm9wcGVkIDAsIG92ZXJsaW1pdHMgNDk5NjQgcmVxdWV1ZXMgMCkgCiBiYWNr
bG9nIDBiIDdwIHJlcXVldWVzIDAgCiAgYm9ycm93ZWQgMCBvdmVyYWN0aW9ucyAxIGF2Z2lk
bGUgLTIwMzEgdW5kZXJ0aW1lIDEyNQpXZWQgQXVnIDEzIDE1OjI5OjI2IE1TRCAyMDE0CmNs
YXNzIGNicSAxOiByb290IHJhdGUgMTAwMDAwS2JpdCBjZWxsIDUxMmIgKGJvdW5kZWQsaXNv
bGF0ZWQpIHByaW8gbm8tdHJhbnNtaXQvOCB3ZWlnaHQgMTAwMDAwS2JpdCBhbGxvdCAxNTE0
YiAKbGV2ZWwgMSBld21hIDUgYXZwa3QgNjU1MzZiIG1heGlkbGUgMTYzdXMgCiBTZW50IDUz
NzYyNDQ4NyBieXRlcyA4MDcwIHBrdCAoZHJvcHBlZCAwLCBvdmVybGltaXRzIDAgcmVxdWV1
ZXMgMCkgCiBiYWNrbG9nIDBiIDBwIHJlcXVldWVzIDAgCiAgYm9ycm93ZWQgMCBvdmVyYWN0
aW9ucyAwIGF2Z2lkbGUgMzE1OTcgdW5kZXJ0aW1lIDAKY2xhc3MgY2JxIDE6MSBwYXJlbnQg
MTogcmF0ZSA3MDAwMEtiaXQgY2VsbCA1MTJiIChib3VuZGVkKSBwcmlvIG5vLXRyYW5zbWl0
LzggYWxsb3QgNjU1MzZiIApsZXZlbCAwIGV3bWEgNSBhdnBrdCA2NTUzNmIgbWF4aWRsZSAx
NjN1cyAKIFNlbnQgMTMzNTA4IGJ5dGVzIDI1IHBrdCAoZHJvcHBlZCAwLCBvdmVybGltaXRz
IDU1OTY2IHJlcXVldWVzIDApIAogYmFja2xvZyAwYiA3cCByZXF1ZXVlcyAwIAogIGJvcnJv
d2VkIDAgb3ZlcmFjdGlvbnMgMiBhdmdpZGxlIC0yNDAyIHVuZGVydGltZSAzODc1CldlZCBB
dWcgMTMgMTU6Mjk6MjkgTVNEIDIwMTQKY2xhc3MgY2JxIDE6IHJvb3QgcmF0ZSAxMDAwMDBL
Yml0IGNlbGwgNTEyYiAoYm91bmRlZCxpc29sYXRlZCkgcHJpbyBuby10cmFuc21pdC84IHdl
aWdodCAxMDAwMDBLYml0IGFsbG90IDE1MTRiIApsZXZlbCAxIGV3bWEgNSBhdnBrdCA2NTUz
NmIgbWF4aWRsZSAxNjN1cyAKIFNlbnQgNTM3NjM3MzYwIGJ5dGVzIDgwNzkgcGt0IChkcm9w
cGVkIDAsIG92ZXJsaW1pdHMgMCByZXF1ZXVlcyAwKSAKIGJhY2tsb2cgMGIgMHAgcmVxdWV1
ZXMgMCAKICBib3Jyb3dlZCAwIG92ZXJhY3Rpb25zIDAgYXZnaWRsZSAyMzc0OCB1bmRlcnRp
bWUgMApjbGFzcyBjYnEgMToxIHBhcmVudCAxOiByYXRlIDcwMDAwS2JpdCBjZWxsIDUxMmIg
KGJvdW5kZWQpIHByaW8gbm8tdHJhbnNtaXQvOCBhbGxvdCA2NTUzNmIgCmxldmVsIDAgZXdt
YSA1IGF2cGt0IDY1NTM2YiBtYXhpZGxlIDE2M3VzIAogU2VudCAxNDU2MjAgYnl0ZXMgMjYg
cGt0IChkcm9wcGVkIDAsIG92ZXJsaW1pdHMgMTUzMjU2IHJlcXVldWVzIDApIAogYmFja2xv
ZyAwYiA2cCByZXF1ZXVlcyAwIAogIGJvcnJvd2VkIDAgb3ZlcmFjdGlvbnMgMyBhdmdpZGxl
IC0yNjU0IHVuZGVydGltZSA1OTUzCldlZCBBdWcgMTMgMTU6Mjk6MzMgTVNEIDIwMTQKY2xh
c3MgY2JxIDE6IHJvb3QgcmF0ZSAxMDAwMDBLYml0IGNlbGwgNTEyYiAoYm91bmRlZCxpc29s
YXRlZCkgcHJpbyBuby10cmFuc21pdC84IHdlaWdodCAxMDAwMDBLYml0IGFsbG90IDE1MTRi
IApsZXZlbCAxIGV3bWEgNSBhdnBrdCA2NTUzNmIgbWF4aWRsZSAxNjN1cyAKIFNlbnQgNTM3
NjM3ODgyIGJ5dGVzIDgwODQgcGt0IChkcm9wcGVkIDAsIG92ZXJsaW1pdHMgMCByZXF1ZXVl
cyAwKSAKIGJhY2tsb2cgMGIgMHAgcmVxdWV1ZXMgMCAKICBib3Jyb3dlZCAwIG92ZXJhY3Rp
b25zIDAgYXZnaWRsZSAyMDI2NSB1bmRlcnRpbWUgMApjbGFzcyBjYnEgMToxIHBhcmVudCAx
OiByYXRlIDcwMDAwS2JpdCBjZWxsIDUxMmIgKGJvdW5kZWQpIHByaW8gbm8tdHJhbnNtaXQv
OCBhbGxvdCA2NTUzNmIgCmxldmVsIDAgZXdtYSA1IGF2cGt0IDY1NTM2YiBtYXhpZGxlIDE2
M3VzIAogU2VudCAxNDU2MjAgYnl0ZXMgMjYgcGt0IChkcm9wcGVkIDAsIG92ZXJsaW1pdHMg
MTY3MDc5IHJlcXVldWVzIDApIAogYmFja2xvZyAwYiA3cCByZXF1ZXVlcyAwIAogIGJvcnJv
d2VkIDAgb3ZlcmFjdGlvbnMgMyBhdmdpZGxlIC0yNjU0IHVuZGVydGltZSAyODI4CldlZCBB
dWcgMTMgMTU6Mjk6MzcgTVNEIDIwMTQKY2xhc3MgY2JxIDE6IHJvb3QgcmF0ZSAxMDAwMDBL
Yml0IGNlbGwgNTEyYiAoYm91bmRlZCxpc29sYXRlZCkgcHJpbyBuby10cmFuc21pdC84IHdl
aWdodCAxMDAwMDBLYml0IGFsbG90IDE1MTRiIApsZXZlbCAxIGV3bWEgNSBhdnBrdCA2NTUz
NmIgbWF4aWRsZSAxNjN1cyAKIFNlbnQgNTM3NjQ2NDY5IGJ5dGVzIDgwOTMgcGt0IChkcm9w
cGVkIDAsIG92ZXJsaW1pdHMgMCByZXF1ZXVlcyAwKSAKIGJhY2tsb2cgMGIgMHAgcmVxdWV1
ZXMgMCAKICBib3Jyb3dlZCAwIG92ZXJhY3Rpb25zIDAgYXZnaWRsZSAxNTIzMiB1bmRlcnRp
bWUgMApjbGFzcyBjYnEgMToxIHBhcmVudCAxOiByYXRlIDcwMDAwS2JpdCBjZWxsIDUxMmIg
KGJvdW5kZWQpIHByaW8gbm8tdHJhbnNtaXQvOCBhbGxvdCA2NTUzNmIgCmxldmVsIDAgZXdt
YSA1IGF2cGt0IDY1NTM2YiBtYXhpZGxlIDE2M3VzIAogU2VudCAxNTMyNTYgYnl0ZXMgMjgg
cGt0IChkcm9wcGVkIDAsIG92ZXJsaW1pdHMgMjAzMDU1IHJlcXVldWVzIDApIAogYmFja2xv
ZyAwYiA3cCByZXF1ZXVlcyAwIAogIGJvcnJvd2VkIDAgb3ZlcmFjdGlvbnMgNCBhdmdpZGxl
IC0yMTIgdW5kZXJ0aW1lIDI4NjAK
--------------070807000604010902040002--
