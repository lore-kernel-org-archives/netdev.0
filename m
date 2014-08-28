From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: net_ns cleanup / RCU overhead
Date: Thu, 28 Aug 2014 15:33:42 -0500
Message-ID: <87oav4l5g9.fsf@x220.int.ebiederm.org>
References: <20140820055855.GB5579@hostway.ca>
	<20140828192431.GF5001@linux.vnet.ibm.com>
	<20140828194422.GB8867@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140828194422.GB8867@hostway.ca> (Simon Kirby's message of
	"Thu, 28 Aug 2014 12:44:22 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Kirby <sim@hostway.ca> writes:

> On Thu, Aug 28, 2014 at 12:24:31PM -0700, Paul E. McKenney wrote:
>
>> On Tue, Aug 19, 2014 at 10:58:55PM -0700, Simon Kirby wrote:
>> > Hello!
>> > 
>> > In trying to figure out what happened to a box running lots of vsftpd
>> > since we deployed a CONFIG_NET_NS=y kernel to it, we found that the
>> > (wall) time needed for cleanup_net() to complete, even on an idle box,
>> > can be quite long:
>> > 
>> > #!/bin/bash
>> > 
>> > ip netns delete test >&/dev/null
>> > while ip netns add test; do
>> >         echo hi
>> >         ip netns delete test
>> > done
>> > 
>> > On my desktop and typical hosts, this prints at only around 4 or 6 per
>> > second. While this is happening, "vmstat 1" reports 100% idle, and there
>> > there are D-state processes with stacks similar to:
>> > 
>> > 30566 [kworker/u16:1] D wait_rcu_gp+0x48, synchronize_sched+0x2f, cleanup_net+0xdb, process_one_work+0x175, worker_thread+0x119, kthread+0xbb, ret_from_fork+0x7c, 0xffffffffffffffff
>> > 
>> > 32220 ip              D copy_net_ns+0x68, create_new_namespaces+0xfc, unshare_nsproxy_namespaces+0x66, SyS_unshare+0x159, system_call_fastpath+0x16, 0xffffffffffffffff
>> > 
>> > copy_net_ns() is waiting on net_mutex which is held by cleanup_net().
>> > 
>> > vsftpd uses CLONE_NEWNET to set up privsep processes. There is a comment
>> > about it being really slow before 2.6.35 (it avoids CLONE_NEWNET in that
>> > case). I didn't find anything that makes 2.6.35 any faster, but on Debian
>> > 2.6.36-5-amd64, I notice it does seem to be a bit faster than 3.2, 3.10,
>> > 3.16, though still not anything I'd ever want to rely on per connection.
>> > 
>> > C implementation of the above: http://0x.ca/sim/ref/tools/netnsloop.c
>> > 
>> > Kernel stack "top": http://0x.ca/sim/ref/tools/pstack
>> > 
>> > What's going on here?
>> 
>> That is a bit slow for many configurations, but there are some exceptions.
>> 
>> So, what is your kernel's .config?
>
> I was unable to find a config (or stock kernel) that was any different,
> but here's the one we're using: http://0x.ca/sim/ref/3.10/config-3.10.53
>
> How fast does the above test run for you?
>
> We've been running with the attached, which has helped a little, but it's
> still quite slow in our particular use case (vsftpd), and with the above
n> test. Should I enable RCU_TRACE or STALL_INFO with a low timeout or
> something?

I just want to add a little bit more analysis to this.

What we desire to be fast is the copy_net_ns, cleanup_net is batched and
asynchronous which nothing really cares how long it takes except that
cleanup_net holds the net_mutex and thus blocks copy_net_ns.

The puzzle is why and which rcu delays Simon is seeing in the network
namespace cleanup path, as it seems like the synchronize_rcu is not
the only one, and in the case of vsftp with trivail network namespaces
where nothing has been done we should not need to delay.

Eric


> Simon-
>
> -- >8 --
> Subject: [PATCH] netns: use synchronize_rcu_expedited instead of
>  synchronize_rcu
>
> Similar to ef323088, with synchronize_rcu(), we are only able to create
> and destroy about 4 or 7 net namespaces per second, which really puts a
> dent in the performance of programs attempting to use CLONE_NEWNET for
> privilege separation (vsftpd, chromium).
> ---
>  net/core/net_namespace.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 85b6269..6dcb4b3 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -296,7 +296,7 @@ static void cleanup_net(struct work_struct *work)
>  	 * This needs to be before calling the exit() notifiers, so
>  	 * the rcu_barrier() below isn't sufficient alone.
>  	 */
> -	synchronize_rcu();
> +	synchronize_rcu_expedited();
>  
>  	/* Run all of the network namespace exit methods */
>  	list_for_each_entry_reverse(ops, &pernet_list, list)
