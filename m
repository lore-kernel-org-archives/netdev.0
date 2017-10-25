From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 00/20] net: sched: convert cls ndo_setup_tc
 offload calls to per-block callbacks
Date: Wed, 25 Oct 2017 15:42:11 +0200
Message-ID: <20171025134211.GA1976@nanopsycho.orion>
References: <20171019135048.4306-1-jiri@resnulli.us>
 <20171021.030446.967534081159629805.davem@davemloft.net>
 <CAKgT0Ud0RJLZ6mz9Ysb9A7PdkcwBYt2+ASvLZQxMGPK2BwvqKw@mail.gmail.com>
 <20171025121503.GA1910@nanopsycho>
 <aaa66a3d-766b-f758-692a-eba7f5a8702f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
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
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>,
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:54859 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932177AbdJYNmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 09:42:13 -0400
Received: by mail-wm0-f44.google.com with SMTP id r68so2053193wmr.3
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 06:42:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <aaa66a3d-766b-f758-692a-eba7f5a8702f@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 25, 2017 at 03:29:27PM CEST, ogerlitz@mellanox.com wrote:
>On 10/25/2017 3:15 PM, Jiri Pirko wrote:
>> > 2. Deleting the ingress qdisc fails to remove filters added in
>> > HW. Filters in SW gets deleted.
>> > 
>> > We haven’t exactly root-caused this, the changes being extensive, but our guess is again something wrong with the offload check or similar while unregistering the block callback (tcf_block_cb_unregister) and further to the classifier (CLS_U32/CLS_FLOWER etc.) with the DESTROY/REMOVE command.
>> Hmm. How does this worked previously. I mean, do you see change of
>> behaviour? I'm asking because I don't see how rules added only to HW
>> could be removed, driver should care of it. Or are you talking about
>> rules added to both SW and HW?
>
>Jiri, on a possibly related note, dealing with some other tc/flower problems

Unrelated. What you describe is a separate issue.


>on net, I came across a situation where we fail in the driverto offload some
>flow (return -EINVALtowards the stack), and we immediately get a call from
>the stack to delete this flow (f->cookie)
>
>this is the cookie and thereturn value
>
>mlx5e_configure_flower f->cookie c50e8c80 err -22
>
>and then we getthis cookie for deletion where we fail again, b/c the flow is
>not offloaded
>
>mlx5e_delete_flower f->cookie c50e8c80

Yes, that is intentional. The thing is, there might be multiple block
callbacks registered and to be called. If there is a fail with one, we
need to cleanup all. So in your case you have 1 cb registered, that
means that in case of an error during insertion, you will get cb called
to remove. Driver has to take care of that. I was checking that and was
under impression that mlx5 deals with that.
