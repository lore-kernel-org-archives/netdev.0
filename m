From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v2 net-next 4/4] net/sched: act_mirred: Implement
 ingress actions
Date: Thu, 29 Sep 2016 13:35:36 +0300
Message-ID: <20160929133536.79de5ae6@halley>
References: <1475009975-30332-1-git-send-email-shmulik.ladkani@gmail.com>
        <1475009975-30332-5-git-send-email-shmulik.ladkani@gmail.com>
        <1475011633.28155.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35355 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755335AbcI2Kfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 06:35:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id b4so10071898wmb.2
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 03:35:43 -0700 (PDT)
In-Reply-To: <1475011633.28155.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, 27 Sep 2016 14:27:13 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> Since this runs lockless, another cpu might change m->tcfm_eaction in
> the middle, and you could call dev_queue_xmit(skb2) while the skb2 was
> prepared for the opposite action.

Well, seem members of 'struct tcf_mirred' are out of sync wrt to each
other, even in existing code, regadless this patch:

- 'tcfm_dev' may be assigned, but 'tcfm_ok_push' not yet updated,
  may result in skb_push_rcsum being called/not called

- 'tcfm_eaction' is changed, in between "mirror is always swallowed" to
  the final 'out:' label,
  may result in wrong tc_verd assigned (or lack of assignment)

Seems the whole "params" need be rcu_dereferenced, like in
tunnel_key_act, or like your suggestion in
  https://patchwork.ozlabs.org/patch/667680/.

I'm gonna fix the new problem you pointed out, by reading-once
'tcfm_eaction' early (right when tcfm_dev is dereferenced) knowing this
is just "keeping things as is wrt running lockless", without introducing
any new non-coherent code.

Thanks,
Shmulik
