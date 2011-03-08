From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] bonding: fix netpoll in active-backup mode
Date: Tue, 08 Mar 2011 16:26:36 +0800
Message-ID: <4D75E83C.5030609@redhat.com>
References: <1299507114-12144-1-git-send-email-amwang@redhat.com> <20110307185038.GA31788@hmsreliant.think-freely.org> <4D75AD50.7060400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D75AD50.7060400@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2011=E5=B9=B403=E6=9C=8808=E6=97=A5 12:15, Cong Wang =E5=86=99=
=E9=81=93:
> =E4=BA=8E 2011=E5=B9=B403=E6=9C=8808=E6=97=A5 02:50, Neil Horman =E5=86=
=99=E9=81=93:
>> On Mon, Mar 07, 2011 at 10:11:50PM +0800, Amerigo Wang wrote:
>>> netconsole doesn't work in active-backup mode, because we don't do =
anything
>>> for nic failover in active-backup mode. This patch fixes the proble=
m by:
>>>
>>> 1) make slave_enable_netpoll() and slave_disable_netpoll() callable=
 in softirq
>>> context, that is, moving code after synchronize_rcu_bh() into call_=
rcu_bh()
>>> callback function, teaching kzalloc() to use GFP_ATOMIC.
>>>
>>> 2) disable netpoll on old slave and enable netpoll on the new slave=
=2E
>>>
>>> Tested by ifdown the current active slave and ifup it again for sev=
eral times,
>>> netconsole works well.
>>>
>>> Signed-off-by: WANG Cong<amwang@redhat.com>
>>>
>> I may be missing soething but this seems way over-complicated to me.=
 I presume
>> the problem is that in active backup mode a failover results in the =
new active
>> slave not having netpoll setup on it? If thats the case, why not jus=
t setup
>> netpoll on all slaves when ndo_netpoll_setup is called on the bondin=
g interface?
>> I don't see anything immeidately catastrophic that would happen as a=
 result.
>
>
> But we still need to clean up the netpoll on the failing slave, which=
 still
> needs to call slave_disable_netpoll() in monitor code, I see no big d=
ifferences
> with the solution I take.
>
>
>> And then you wouldn't have to worry about disabling/enabling anythin=
g on a
>> failover (or during a panic for that matter). As for the rcu bits? W=
hy are
>> they needed? One would presume that wouldn't (or at least shouldn't)=
 be able to
>> teardown our netpoll setup until such time as all the pending frames=
 for that
>> netpoll client have been transmitted. If we're not blocknig on that =
RCU isn't
>> really going to help. Seems like the proper fix is take a reference =
to the
>> appropriate npinfo struct in netpoll_send_skb, and drop it from the =
skbs
>> destructor or some such.
>
> I saw a "scheduling while in atomic" warning without touching the rcu=
 bits.
>

Hmm, I was wrong, this warning is misleading, I think the root cause is=
 that
I call slave_disable_netpoll() with write_lock_bh() held...

Will update the patch soon...
