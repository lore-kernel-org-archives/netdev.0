From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 0/1] ip_tunnel: Create percpu gro_cell
Date: Fri, 16 Jan 2015 10:10:59 -0800
Message-ID: <1421431860-1960597-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:28943 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755525AbbAPSLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:11:14 -0500
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t0GIB172032398
	for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 10:11:14 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ry6xag67c-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 10:11:13 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 0d1836709dab11e4ba470002c991e86a-12bdc390 for <netdev@vger.kernel.org>;	Fri,
 16 Jan 2015 10:11:11 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
All skb will be queued to the same cell->napi_skbs.  The
gro_cell_poll is pinned to one core under load. In production traffic,
we also see severe rx_dropped in the tunl iface and it is probably due to
this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog

This patch is trying to alloc_percpu(struct gro_cell) and schedule
gro_cell_poll to process the skb in the same core.

Changes from v1:
Eric Dumazet pointed out that ____cacheline_aligned_in_smp is no longer needed.

Changes from v2:
Dropped the one-item-struct cleanup patch per comment.

Setup:
VIP_PREFIX=9.9.9.9/32
REMOTE_REAL_IP=10.228.95.75

if [ "$1" = "encap" ]
then
    sudo ip tunnel add mode ipip remote ${REMOTE_REAL_IP}
    sudo ip link set dev ipip0 up
    sudo ip route add dev ipip0 ${VIP_PREFIX}
else
    # Decapsulating host

    sudo ip tunnel add mode ipip
    sudo ip link set dev tunl0 up
    sudo ip addr add dev lo ${VIP_PREFIX}
    sudo sysctl -a  | grep '\.rp_filter' | awk '{print $1;}' | \
        xargs -n1 -I{} sudo sysctl {}=0
fi

Before:
[root@DECAP ~]# netserver -p 8888
[root@ENCAP ~]# super_netperf 200 -t TCP_RR -H 9.9.9.9 -p 8888 \
-l 30 -- -d 0x6 -m 8k,64k -s 1M -S 1M
332215
[root@DECAP ~]# perf probe -a gro_cell_poll
[root@DECAP ~]# perf stat -I 1000 -a -A -e probe:gro_cell_poll
   117.258518273 CPU0                     0      probe:gro_cell_poll
   117.258518273 CPU1                     0      probe:gro_cell_poll
   117.258518273 CPU2                     0      probe:gro_cell_poll
   117.258518273 CPU3                     0      probe:gro_cell_poll
   117.258518273 CPU4                     0      probe:gro_cell_poll
   117.258518273 CPU5                     0      probe:gro_cell_poll
   117.258518273 CPU6                     0      probe:gro_cell_poll
   117.258518273 CPU7                     0      probe:gro_cell_poll
   117.258518273 CPU8                     0      probe:gro_cell_poll
   117.258518273 CPU9                     0      probe:gro_cell_poll
   117.258518273 CPU10                    0      probe:gro_cell_poll
   117.258518273 CPU11                    0      probe:gro_cell_poll
   117.258518273 CPU12                    0      probe:gro_cell_poll
   117.258518273 CPU13                    0      probe:gro_cell_poll
   117.258518273 CPU14                    0      probe:gro_cell_poll
   117.258518273 CPU15                4,882      probe:gro_cell_poll
   117.258518273 CPU16                    0      probe:gro_cell_poll
   117.258518273 CPU17                    0      probe:gro_cell_poll
   117.258518273 CPU18                    0      probe:gro_cell_poll
   117.258518273 CPU19                    0      probe:gro_cell_poll
   117.258518273 CPU20                    0      probe:gro_cell_poll
   117.258518273 CPU21                    0      probe:gro_cell_poll
   117.258518273 CPU22                    0      probe:gro_cell_poll
   117.258518273 CPU23                    0      probe:gro_cell_poll
   117.258518273 CPU24                    0      probe:gro_cell_poll
   117.258518273 CPU25                    0      probe:gro_cell_poll
   117.258518273 CPU26                    0      probe:gro_cell_poll
   117.258518273 CPU27                    0      probe:gro_cell_poll
   117.258518273 CPU28                    0      probe:gro_cell_poll
   117.258518273 CPU29                    0      probe:gro_cell_poll
   117.258518273 CPU30                    0      probe:gro_cell_poll
   117.258518273 CPU31                    0      probe:gro_cell_poll
   117.258518273 CPU32                    0      probe:gro_cell_poll
   117.258518273 CPU33                    0      probe:gro_cell_poll
   117.258518273 CPU34                    0      probe:gro_cell_poll
   117.258518273 CPU35                    0      probe:gro_cell_poll
   117.258518273 CPU36                    0      probe:gro_cell_poll
   117.258518273 CPU37                    0      probe:gro_cell_poll
   117.258518273 CPU38                    0      probe:gro_cell_poll
   117.258518273 CPU39                    0      probe:gro_cell_poll

After:
[root@DECAP ~]# netserver -p 8888
[root@ENCAP ~]# super_netperf 200 -t TCP_RR -H 9.9.9.9 -p 8888 \
-l 30 -- -d 0x6 -m 8k,64k -s 1M -S 1M
877530
[root@DECAP ~]# perf probe -a gro_cell_poll
[root@DECAP ~]# perf stat -I 1000 -a -A -e probe:gro_cell_poll
    40.085714389 CPU0                13,607      probe:gro_cell_poll
    40.085714389 CPU1                13,188      probe:gro_cell_poll
    40.085714389 CPU2                12,913      probe:gro_cell_poll
    40.085714389 CPU3                12,790      probe:gro_cell_poll
    40.085714389 CPU4                13,395      probe:gro_cell_poll
    40.085714389 CPU5                13,121      probe:gro_cell_poll
    40.085714389 CPU6                11,083      probe:gro_cell_poll
    40.085714389 CPU7                12,945      probe:gro_cell_poll
    40.085714389 CPU8                13,704      probe:gro_cell_poll
    40.085714389 CPU9                13,514      probe:gro_cell_poll
    40.085714389 CPU10                    0      probe:gro_cell_poll
    40.085714389 CPU11                    0      probe:gro_cell_poll
    40.085714389 CPU12                    0      probe:gro_cell_poll
    40.085714389 CPU13                    0      probe:gro_cell_poll
    40.085714389 CPU14                    0      probe:gro_cell_poll
    40.085714389 CPU15                    0      probe:gro_cell_poll
    40.085714389 CPU16                    0      probe:gro_cell_poll
    40.085714389 CPU17                    0      probe:gro_cell_poll
    40.085714389 CPU18                    0      probe:gro_cell_poll
    40.085714389 CPU19                    0      probe:gro_cell_poll
    40.085714389 CPU20               10,402      probe:gro_cell_poll
    40.085714389 CPU21               12,312      probe:gro_cell_poll
    40.085714389 CPU22               11,913      probe:gro_cell_poll
    40.085714389 CPU23               12,964      probe:gro_cell_poll
    40.085714389 CPU24               13,727      probe:gro_cell_poll
    40.085714389 CPU25               12,943      probe:gro_cell_poll
    40.085714389 CPU26               13,558      probe:gro_cell_poll
    40.085714389 CPU27               12,676      probe:gro_cell_poll
    40.085714389 CPU28               13,754      probe:gro_cell_poll
    40.085714389 CPU29               13,379      probe:gro_cell_poll
    40.085714389 CPU30                    0      probe:gro_cell_poll
    40.085714389 CPU31                    0      probe:gro_cell_poll
    40.085714389 CPU32                    0      probe:gro_cell_poll
    40.085714389 CPU33                    0      probe:gro_cell_poll
    40.085714389 CPU34                    0      probe:gro_cell_poll
    40.085714389 CPU35                    0      probe:gro_cell_poll
    40.085714389 CPU36                    0      probe:gro_cell_poll
    40.085714389 CPU37                    0      probe:gro_cell_poll
    40.085714389 CPU38                    0      probe:gro_cell_poll
    40.085714389 CPU39                    0      probe:gro_cell_poll
