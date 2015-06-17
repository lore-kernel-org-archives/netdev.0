From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 43/43] netfilter: Skip unnecessary calls to synchronize_net
Date: Wed, 17 Jun 2015 15:32:05 -0500
Message-ID: <87lhfi84ai.fsf@x220.int.ebiederm.org>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
	<1434554932-4552-43-git-send-email-ebiederm@xmission.com>
	<20150617172054.GJ13215@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150617172054.GJ13215@acer.localdomain> (Patrick McHardy's
	message of "Wed, 17 Jun 2015 19:20:54 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> On 17.06, Eric W. Biederman wrote:
>> From: Eric W Biederman <ebiederm@xmission.com>
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  net/netfilter/core.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
>> index 95456c09cf69..1b4eadc9c030 100644
>> --- a/net/netfilter/core.c
>> +++ b/net/netfilter/core.c
>> @@ -134,7 +134,9 @@ void nf_unregister_hook(struct net *net, const struct nf_hook_ops *reg)
>>  #ifdef HAVE_JUMP_LABEL
>>  	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>>  #endif
>> -	synchronize_net();
>> +	/* Don't wait if there are no packets in flight */
>> +	if (net->loopback_dev)
>> +		synchronize_net();
>
> I don't get this, could you please explain why there wouldn't be any packets
> in flight if there is no loopback_dev?

The simplified version.

Typical netfilter module:
> static struct nf_hook_ops mod_ops[] __read_mostly = {
> 	...
> };
> static int __net_init mod_init(struct net *net)
> {
>         return nf_register_hooks(net, mod_ops, ARRAY_SIZE(mod_ops));
> }
> static void __net_exit mod_net_exit(struct net *net)
> {
> 	nf_unregister_hooks(net, mod_ops, ARRAY_SIZE(mod_ops));
> }
> static struct pernet_operations mod_net_ops = {
> 	.init =  mod_net_init,
> 	.exit =  mod_net_exit,
> };
> static int __init mod_init(void)
> {
> 	return register_pernet_subsys(&mod_net_ops);
> }
> static void __exit mod_fini(void)
> {
> 	unregister_pernet_subsys(&mod_net_ops);
> }

Which means there are essentially two times when nf_unregister_hook is
called:
- At some random time when the netfilter module is being removed.
- From unregister_pernet_subsys.

It is an invariant of subsys code called from the network namespace
exit path that no packets are in flight.  Without that invariant
it is a nightmare to clean up data structures, etc.

The last thing that happens before the network namespace subsystem
exit routines are called is the loopback device is freed.

That happens in default_device_exit_batch in the rtnl_unlock() call.


Another way to look at it is that:  I know there are no user space
sockets, and I know that there are no networking devices by the time
the loopback device is freed as part of network namespace clean up.
Which removes all sources of packets.

Additionally we have to perform all of the rcu waits before we can free
any network device and with the loopback device being the last network
device freed those waits have all been performed.


The network stack also goes kaboom in the most interesting ways when we
goof up and violate the rule that guarantee that packets are not in
flight when unregistering.  I have not seen that in years.


And my older documentation in net_namespace.h says:
> /*
>  * Use these carefully.  If you implement a network device and it
>  * needs per network namespace operations use device pernet operations,
>  * otherwise use pernet subsys operations.
>  *
>  * Network interfaces need to be removed from a dying netns _before_
>  * subsys notifiers can be called, as most of the network code cleanup
>  * (which is done from subsys notifiers) runs with the assumption that
>  * dev_remove_pack has been called so no new packets will arrive during
>  * and after the cleanup functions have been called.  dev_remove_pack
>  * is not per namespace so instead the guarantee of no more packets
>  * arriving in a network namespace is provided by ensuring that all
>  * network devices and all sockets have left the network namespace
>  * before the cleanup methods are called.
>  *
>  * For the longest time the ipv4 icmp code was registered as a pernet
>  * device which caused kernel oops, and panics during network
>  * namespace cleanup.   So please don't get this wrong.
>  */
> int register_pernet_subsys(struct pernet_operations *);
> void unregister_pernet_subsys(struct pernet_operations *);
> int register_pernet_device(struct pernet_operations *);
> void unregister_pernet_device(struct pernet_operations *);


Another more explicit way of looking at this in the context of
netfilter:
- The loopback device is free (which is the mast network device to be
  freed) so there are no more network devices.
- Therefore the netfilter tracepoints can no longer be called.
- Therefore the worst we are dealing with is someone accessing
  a network device via an rcu.
- The rcu_barrier() after NETDEV_UNREGISTER in netdev_run_todo()
  is there so that a network device can assume that it has no rcu
  references from packets or other things.
- We know the loopback device and all other network devices before it 
  have passed that rcu_barrier in netdev_run_todo().

- Or in short: loopback_dev == NULL means we have no network devices and
  an rcu grace perioed has elapsed since the last network device was
  freed.

Therefore loopback_dev == NULL is a strong and reliable indication that
we don't have any packets in flight in a network namespace.

Hmm.  I wonder if we might want to implement a function:
void syncrhonize_net_namespace(struct net *net)
{
	if (net->loopback_dev)
		synchronize_net();
}
Just to make it easier to take advantage of this knowledge.

What I do know is that without taking advantage of the fact we have
no packets in flight.  We will get a ton of synrhonize_net calls in
the network namespace destruction with this change which will slow
the connection rates of vsftp to a crawl as it will try to create a new
network namespace for a new connection and have to wait until all of the
pending network namespace destructions have completed.  Sigh.

So I put in this code to prevent a nasty performance regeression.

Eric
