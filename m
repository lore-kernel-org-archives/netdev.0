From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: crypto: deadlock between crypto_alg_sem/rtnl_mutex/genl_mutex
Date: Wed, 15 Mar 2017 07:30:19 -0400
Message-ID: <20170315113019.GA28050@oracle.com>
References: <CACT4Y+bLbNbf0T376JHvemuY+za0+qgrfOKWzvJg5vAkJTCRFg@mail.gmail.com>
 <CACT4Y+bJ1-d3DhCvzEN0PeDd7+P2LNgjF2NHwALXBubOKaOEsw@mail.gmail.com>
 <CACT4Y+YhLM0CetOZn6uXwyBBGM_oVsW-CC3NMg8A5K0xd3F2mA@mail.gmail.com>
 <CACT4Y+YTBPDMOZGMLuZPaQhSFXbeQeahHc8BUDOgNYm6hRy6fw@mail.gmail.com>
 <20170314152519.GA21159@oracle.com>
 <CACT4Y+a+SHMAB=xsMahgawEsQKRNVp0dgc6v3pv=TADqADsLpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        netdev <netdev@vger.kernel.org>, santosh.shilimkar@oracle.com,
        rds-devel@oss.oracle.com, syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+a+SHMAB=xsMahgawEsQKRNVp0dgc6v3pv=TADqADsLpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (03/15/17 10:08), Dmitry Vyukov wrote:
> After I've applied the patch these reports stopped to happen, and I
> have not seem any other reports that look relevant.
> However, it there was one, but it looks like a different issue and it
> was probably masked by massive amounts of original deadlock reports:

Yes, this looks like a valid deadlock.

I think there may be some ->dumpit callbacks that take the rtnl_lock
and do not unlock it before return, e.g., I see nl80211_dump_interface()
doing this at 

   2612         rtnl_lock();
   2613         if (!cb->args[2]) {
     :
   2619                 ret = nl80211_dump_wiphy_parse(skb, cb, &state);
   2620                 if (ret)
   2621                         return ret;

afaict, nl80211_dump_wiphy_parse does not itself do rtnl_unlock on error.


If that's the case then we'd run into the circular locking dependancy
flagged by lockdep. 

Disclaimer: I did not check every single ->dumpit, there may be more
than one of these..
