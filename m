From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: problem with MPLS and TSO/GSO
Date: Tue, 9 Aug 2016 21:52:01 -0600
Message-ID: <d99610e6-7f88-6fb9-a971-e1ae3da6001d@cumulusnetworks.com>
References: <20160725163915.GE10080@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33725 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581AbcHJDwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 23:52:04 -0400
Received: by mail-pf0-f173.google.com with SMTP id y134so11433250pfg.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 20:52:04 -0700 (PDT)
In-Reply-To: <20160725163915.GE10080@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/25/16 10:39 AM, Lennert Buytenhek wrote:
> Hi!
> 
> I am seeing pretty horrible TCP transmit performance (anywhere between
> 1 and 10 Mb/s, on a 10 Gb/s interface) when traffic is sent out over a
> route that involves MPLS labeling, and this seems to be due to an
> interaction between MPLS and TSO/GSO that causes all segmentable TCP
> frames that are MPLS-labeled to be dropped on egress.
...
> But, loading mpls_gso doesn't change much -- skb_gso_segment() then
> starts return -EINVAL instead, which is due to the
> skb_network_protocol() call in skb_mac_gso_segment() returning zero.
> And looking at skb_network_protocol(), I don't see how this is
> supposed to work -- skb->protocol is 0 at this point, and there is no
> way to figure out that what we are encapsulating is IP traffic, because
> unlike what is the case with VLAN tags, MPLS labels aren't followed by
> an inner ethertype that says what kind of traffic is in here, you have
> to have explicit knowledge of the payload type for MPLS.
> 
> Any ideas?

A quick update. I have a pretty good handle on the GSO changes for MPLS but I am still puzzled by a few things. Hopefully by end of week I can send out a patch series. Current performance comparison with my changes and a patch from Roopa:

MPLS
====
root@kenny-jessie3:~# ip netns exec ns0 netperf -c -C -H 10.10.10.10 -l 10 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.10.10.10 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      3510.26   48.11    48.11    4.491   4.491

non-MPLS
========
root@kenny-jessie3:~# ip netns exec ns0 netperf -c -C -H 172.16.21.22 -l 30 -t TCP_STREAM
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.16.21.22 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    30.00      9654.97   42.37    42.37    1.438   1.438
