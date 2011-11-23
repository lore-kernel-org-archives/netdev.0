From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Wed, 23 Nov 2011 08:05:00 -0800
Message-ID: <4ECD19AC.8090505@intel.com>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322035942.1298.56.camel@edumazet-laptop>
	<1322052463.2039.135.camel@mojatatu>
	<1322052938.17693.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1322055858.2039.188.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322055858.2039.188.camel@mojatatu>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/23/2011 5:44 AM, Jamal Hadi Salim wrote:
> On Wed, 2011-11-23 at 13:55 +0100, Eric Dumazet wrote:
> 
>> Currently thinking about it. I was also waiting Tom Herbert BQL patches.
> 
> Excellent. I can test when you have something.
> 
>> Several people are interested, and John Fastabend told me he plans to :
>>
>>  (1) rcu'ify classifiers/actions as needed
> 
> Makes sense in most cases. If you have a lot of flow setup/teardown
> it may harm.

We could have a CONFIG option to always do locking in some
cases if thats not too ugly.

> Another one - but dont see how much you can do about this; useful
> when you want to share state (eg multiple flows being policed
> by a single rate meter);
> An action could be shared across multiple policies i.e you can
> have:
> match1, action foo instance 1, action bar instance 3
> match2, action bar instance3
> match3, ....
> This could would mean a lock contended across cpus when different
> flows hitting match1/2 show up on different cpus.
>  
>>  (2) add flag to drop qdisc lock on simple or hw qdiscs
> 
> Where does config for the hardware happen from?
> 

I assume you mean something like setup_tc() which we have
today to call into into the driver at qdisc create time. This
happens with the RTNL held. I don't see any reason not to also
call into the hardware on qdisc_change() I just haven't done
it yet.

Although I'm pretty sure we don't want to add a new ndo_ops
ever time we have some hardware feature we want to expose.
Assuming there are more than 1 or 2 hw features. So maybe
we could convert to something more generic. A setup_qos()
call that passes an skb with nl attributes.

Is that what you were asking?

>>  (3) mq and mqprio call root qdisc and run a pass over classifiers
>>      actions possibly resetting queue_mapping.
> 
> 
> It seems to make sense - but I will wait and see to have better
> understanding.

One of the problems this resolves is not being able to
call the classifier-actions until after the queue is
already selected. At this point you can't send it to
a higher/lower priority queue.

I'm traveling for a couple days, but I'll try to get
some actual patches out next week to illustrate this.

Thanks,
John

> 
> cheers,
> jamal
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
