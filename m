From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [3.15-rc3] Bisected: xen-netback mangles packets
 between two guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Tue, 6 May 2014 18:08:16 +0100
Message-ID: <53691700.8090603@citrix.com>
References: <395225650.20140430124506@eikelenboom.it>  <536162D3.5080307@citrix.com> <94755525.20140501002553@eikelenboom.it>  <53624E25.8040404@citrix.com> <1810270947.20140501155911@eikelenboom.it>  <53626C39.3030304@citrix.com> <928229683.20140501193936@eikelenboom.it>  <198418193.20140501213951@eikelenboom.it> <5363A508.1000602@citrix.com>  <653156457.20140502160632@eikelenboom.it> <5363AFED.5080601@citrix.com> <1399044073.29914.237.camel@edumazet-glaptop2.roam.corp.google.com> <5363B929.1000502@citrix.com> <35970097.20140502182818@eikelenboom.it> <5363CBB0.6050804@citrix.com> <15602339.20140505121912@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58537 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbaEFRIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 13:08:20 -0400
In-Reply-To: <15602339.20140505121912@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/05/14 11:19, Sander Eikelenboom wrote:
>
> Hi Zoltan,
>
> This weekend i tried some more things, the summary:
>
>
> 1) It's a PITA to isolate your patches that went into 3.15 (to rule out any other changes) and apply
>     them to 3.14.2, which is tested and worked ok. Could you put up a git tree
>     somewhere and rebase your patch series on 3.14.2 for testing ?
I've managed to repro the case in house, now I'll start to add more 
debug logging
>
> 2) Does the test suite you are using also has tests verifying that the content of packets isn't altered ?
Not directly. But the applications running on top of them probably do 
so. Also, my tests are running on top of 3.10 kernel, where the netback 
changes are backported.
>
> 3) It's possible to simplify the test case to a apache webdav server and a
>     simple curl put, this simplifies testing and puts ssl and duplicity out of the equation.
I just used wget.
>
> 4) There seem to be (at least) two, from the eye of it, separate issues with
>     netback / netfront.
>     a) Assumption that  "An upstream guest shouldn't be able to send 18 slots" is
>        false, which probably triggers the netback tx_frag_overflow case.
>     b) Corruption of packet content when:
>            - sending packets between guests on the same routed network bridge,
>            - sending packets between host (dom) and guest goes ok.
>     c) Both a and b are regressions from 3.14(.2), although at least a) seems just
>        uncovering a latent bug revealed by changed semantics.
>
> 5) Test outcome
>
> --
> Sander
>
> Ad 1) git tree somewhere and rebase your patch series on 3.14.2:
>      This is of course unless you are able to trigger this yourself and debug it with the simplified testcase described in (3).
>
> Ad 3) simplify the test case:
>      My current setup:
>      - working: host kernel 3.14.2 and guest kernels all 3.15-rc4 on Debian wheezy
>      - not working: host and guest kernels all 3.15-rc4 on Debian wheezy (.config attached)
>      - not working: host and guest kernels all 3.15-rc4 + Eric's patch on Debian wheezy (.config attached)
>
>      - guests are on a routed bridge (normal linux kernel bridge which is routed
>        with eth0 and eth1.
>      - receiving guest has apache 2.2 running with mod_dav.
>
>      - test:
>            - create a 100mb testfile with a pattern (used perl script is attached)
>            - Use curl in dom0 or in the sending guest to send the testfile:
>              curl --upload-file testfile.bin http://webdav-guest/storagelocation/
>            - check the md5sum of testfile.bin on both sender and receiver
>
> Ad 4a) Assumption that  "An upstream guest shouldn't be able to send 18 slots":
>      - xen-netfront does this slot check in "xennet_start_xmit":
>          slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>                  xennet_count_skb_frag_slots(skb);
>          if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
>                  net_alert_ratelimited(
>                          "xennet: skb rides the rocket: %d slots\n", slots);
>                  goto drop;
>          }
>
>      - The "MAX_SKB_FRAGS + 1" was changed due to: http://www.gossamer-threads.com/lists/xen/devel/266980,
>        but it doesn't seem to be the proper solution.
>      - So your assumption doesn't hold, MAX_SKB_FRAGS==17, so 18 slots can come through.
>      - On 3.15-rc4 i now started to see this warning getting triggered and packets dropped, i don't see this on 3.14.2:
>        [  118.526583] xen_netfront: xennet: skb rides the rocket: 19 slots | skb_shinfo(skb)->nr_frags: 3, len: 186, offset: 4070, skb->len: 62330, skb->data_len: 62144, skb->truesize: 63424, np->tx.sring->rsp_prod: 21434, np->tx.rsp_cons: 21434  DIV_ROUND_UP(offset + len, PAGE_SIZE): 2
>      - So probably some change in semantics makes this thing popup again.
>      - What i don't understand is why in:
>        xen-netfront this slots check is done when the skb is already dequeued (so dropping is the only thing left to do),
>        while in xen-netback it is done before the packet is dequeued (which now seems to work correct since the fixup of Paul to 3.14)
>
>      - so your assumption isn't true, but it seems netfront needs to be fixed for that.
>
>      - A lot of the (slot) checking logic and frag handling seems to be about the same in xen-netfront and xen-netback, although they seem to have diverted
>        somewhat, wouldn't it make sense to put a lot of the generic helper functions in a xen-netcommon.c and share them ?
>
> Ad 4b) Corruption of packet content:
>      -  The dom0 case doesn't use zerocopy (tx_zerocopy_success: 0 &&  tx_frag_overflow: 0)
>      -  I'm getting less convinced it's (directly) coupled to (4a) and the tx_frag_overflow case, although they can occur at about the same time, it
>         doesn't necesarrily, the testfile is also corrupt when there is no tx_frag_overflow reported for both vifs:
>             ethtool -S vif2.0 (sender)
>             NIC statistics:
>             rx_gso_checksum_fixup: 0
>             tx_zerocopy_sent: 25705
>             tx_zerocopy_success: 25538
>             tx_zerocopy_fail: 167
>             tx_frag_overflow: 0
>
>             ethtool -S vif1.0 (receiver)
>             NIC statistics:
>             rx_gso_checksum_fixup: 0
>             tx_zerocopy_sent: 246916
>             tx_zerocopy_success: 1
>             tx_zerocopy_fail: 246915
>             tx_frag_overflow: 0
>
>
> Ad 5) The test described in (3) results into (repeated 5 times each) these md5sums for testfile.bin::
>      - generated file: fe599e44789799bae5b6db3df9a34e2d
>
>      - dom0 3.14.2        - dom0 to guest:  fe599e44789799bae5b6db3df9a34e2d
>      - dom0 3.14.2        - guest to guest: fe599e44789799bae5b6db3df9a34e2d
>
>      - dom0 3.15-rc4      - dom0 to guest:  fe599e44789799bae5b6db3df9a34e2d
>      - dom0 3.15-rc4      - guest to guest: 2f51d9baad6f7b2c99aa51e14878a55a fb7df5de7d08b6ad24aa9166949de8c9 0c0afc145f4fed9231e4f1ab6243d02f ef83ace3aafd7e57b8b2fbe324d38995 ffab10c9906381415e5697d2c0e05da3
>
>      - dom0 3.15-rc4+eric - dom0 to guest:  fe599e44789799bae5b6db3df9a34e2d
>      - dom0 3.15-rc4+eric - guest to guest: eb8f48c5613478bb0a69a6115570c713 66fc191b4a04ccddd8b926bc2f57c2b9 99891e0397ca119b0cfaea80b0c6b1f0 0899ab428d102791345c67fa4b608b36 4cc2e3badabc465630d8002004fc0fa3
>
>     - That's no good for the guest to guest case .. so inspect the received testfile.bin:
>       - length is exactly the same .. good
>       - beginning and ending magic strings are there .. good
>       - the md5sums differ every time .. no good
>       - diff the files to see what is different (one diff from the hexdumps is attached):
>           - although the byte counting strings should be unique, in the received testfile.bin they are not, for example:
>                 grep -i -n 76234752 testfile2.hex
>                 4764674:048b4010  20 20 20 20 20 20 20 20  37 36 32 33 34 37 35 32  |        76234752|
>                 4764930:048b5010  20 20 20 20 20 20 20 20  37 36 32 33 34 37 35 32  |        76234752|
>
>      - So what do we have so far:
>          - it look likes all packet metadata is correct, so no warnings or errors from the network stack.
>          - only the actual payload gets mangled (otherwise i would have expected warnings from the network stack)
>          - it seems to only get mangled when it is travelling "xen-netfront -> xen-netback -> linux netw. bridge -> xen-netback -> xen-netfront".
>          - it seems NOT to get mangled when it is travelling "xen-netback -> xen-netfront" only.
>          - it's not random corruption, it seems data from older/other frags/packets is used instead of the right data.
>          - and a simple test case ... so i hope you can reproduce.
>
> --
> Sander
>
