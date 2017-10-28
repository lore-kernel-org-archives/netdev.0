From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Sat, 28 Oct 2017 10:43:51 +0200
Message-ID: <20171028084351.GF1980@nanopsycho.orion>
References: <20171019135048.4306-1-jiri@resnulli.us>
 <20171021.030446.967534081159629805.davem@davemloft.net>
 <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <20171025121503.GA1910@nanopsycho>
 <2e4baa66-35e3-0259-6228-ab05ec826345@intel.com>
 <20171027072730.GB1980@nanopsycho.orion>
 <20171027175200.018ebe65@cakuba.netronome.com>
 <20171028072031.GC1980@nanopsycho.orion>
 <20171028005321.3b5817da@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Nambiar, Amritha" <amritha.nambiar@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, mlxsw@mellanox.com,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michael Chan <michael.chan@broadcom.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>, idosch@mellanox.com,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>,
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:50242 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdJ1Inx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 04:43:53 -0400
Received: by mail-wr0-f169.google.com with SMTP id p96so8051150wrb.7
        for <netdev@vger.kernel.org>; Sat, 28 Oct 2017 01:43:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171028005321.3b5817da@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 28, 2017 at 09:53:21AM CEST, kubakici@wp.pl wrote:
>On Sat, 28 Oct 2017 09:20:31 +0200, Jiri Pirko wrote:
>> Sat, Oct 28, 2017 at 02:52:00AM CEST, kubakici@wp.pl wrote:
>> >On Fri, 27 Oct 2017 09:27:30 +0200, Jiri Pirko wrote:  
>> >> Yes, it is the same.  
>> >
>> >FWIW I also see what Amritha and Alex are describing here, for cls_bpf
>> >there are no DESTROYs coming on rmmod or qdisc del.  There is a DESTROY
>> >if I manually remove the filter (or if an ADD with skip_sw fails).  
>> 
>> Is this different to the original behaviour? Just for cls_bpf?
>
>For cls_bpf the callbacks used to be 100% symmetrical, i.e. destroy
>would always be guaranteed if add succeeded (regardless of state of
>skip_* flags).

Hmm. It still should be symmetrical. Looking at following path:
cls_bpf_destroy->
   __cls_bpf_delete->
      cls_bpf_stop_offload->
         cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY)

I don't see how any tp could be missed. Could you please check this
callpath is utilized during your action (rmmod or qdisc del)?


>
>I haven't checked cls_flower on the nfp because it implodes on add
>already...  I hear the fix is simple so I can check, if that helps.
>Although from quick code inspection it seems fl_hw_destroy_filter()
>was always invoked before fl_destroy_filter(), so it looks like since
>flower doesn't track which filters were offloaded successfully it may
>send destroy events for filter drivers don't hold, but destroy should
>always be guaranteed there too.

You are right, that is following path:
fl_delete->
   fl_hw_destroy_filter

I will check it.
