From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 6/8] nfp: bpf: add support for XDP_FLAGS_HW_MODE
Date: Tue, 20 Jun 2017 02:09:54 +0200
Message-ID: <594867D2.4030306@iogearbox.net>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>        <20170616235746.16337-7-jakub.kicinski@netronome.com>        <59486339.8080003@iogearbox.net> <20170619170123.1fc13a70@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kafai@fb.com,
        brouer@redhat.com, oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35146 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753259AbdFTAJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 20:09:59 -0400
In-Reply-To: <20170619170123.1fc13a70@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2017 02:01 AM, Jakub Kicinski wrote:
> On Tue, 20 Jun 2017 01:50:17 +0200, Daniel Borkmann wrote:
>> On 06/17/2017 01:57 AM, Jakub Kicinski wrote:
>>> Respect the XDP_FLAGS_HW_MODE.  When it's set install the program
>>> on the NIC and skip enabling XDP in the driver.
>>>
>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>> ---
>>>    drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 +++++++---
>>>    1 file changed, 7 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
>>> index 68648e312129..c5903b6e58c5 100644
>>> --- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
>>> +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
>>> @@ -3310,19 +3310,22 @@ static int
>>>    nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
>>>    		  struct netlink_ext_ack *extack)
>>>    {
>>> -	struct bpf_prog *offload_prog;
>>> +	struct bpf_prog *drv_prog, *offload_prog;
>>>    	int err;
>>>
>>>    	if (nn->xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
>>>    		return -EBUSY;
>>>
>>> +	drv_prog     = flags & XDP_FLAGS_HW_MODE  ? NULL : prog;
>>>    	offload_prog = flags & XDP_FLAGS_DRV_MODE ? NULL : prog;
>>
>> Can you make this assumption here? If dev_change_xdp_fd() is called
>> without XDP_FLAGS_HW_MODE or XDP_FLAGS_DRV_MODE flags, then we set prog
>> to both, drv_prog and offload_prog. Is this expected?
>>
>> Maybe in nfp_net_xdp_setup() check for !hweight32(xdp_flags & XDP_FLAGS_MODES)
>> and then set flags |= XDP_FLAGS_DRV_MODE before both assignments?
>
> I thought we did want both.  In case the program is loaded to both the
> HW/FW will mark the packets with BPF bit in the descriptor so that they
> are not processed twice.  But the driver path will be configured for
> running bpf and when user replaces the program with one which cannot be
> offloaded the driver will not have to reconfigure itself.

Okay, that's a good point ... so that you can just use xchg() later on.
Probably worth explaining this rationale in a short comment.
