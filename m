From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2 09/10] netns: Add a limit on the number of net
	namespaces
Date: Tue, 26 Jul 2016 15:00:05 -0500
Message-ID: <87d1m0p3ui.fsf@x220.int.ebiederm.org>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
	<20160721164014.17534-1-ebiederm@xmission.com>
	<20160721164014.17534-9-ebiederm@xmission.com>
	<CANaxB-zfkvu9XYkuYB47tYFGLeVnWBhpgEUaSrGD4+-O8ThcNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CANaxB-zfkvu9XYkuYB47tYFGLeVnWBhpgEUaSrGD4+-O8ThcNw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Andrei Vagin's message of "Mon, 25 Jul 2016 23:01:19 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Thu, Jul 21, 2016 at 9:40 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> index 2c2eb1b629b1..a489f192d619 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -266,6 +266,16 @@ struct net *get_net_ns_by_id(struct net *net, int id)
>>         return peer;
>>  }
>>
>> +static bool inc_net_namespaces(struct user_namespace *ns)
>> +{
>> +       return inc_ucount(ns, UCOUNT_NET_NAMESPACES);
>> +}
>> +
>> +static void dec_net_namespaces(struct user_namespace *ns)
>> +{
>> +       dec_ucount(ns, UCOUNT_NET_NAMESPACES);
>> +}
>> +
>>  /*
>>   * setup_net runs the initializers for the network namespace object.
>>   */
>> @@ -276,6 +286,9 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
>>         int error = 0;
>>         LIST_HEAD(net_exit_list);
>>
>> +       if (!inc_net_namespaces(user_ns))
>> +               return -ENFILE;
>
> I think you need to move this check after initilizing  net->passive.
> When setup_net returns an error, net_drop_ns is called:
>
Good point.  Ouch!

> void net_drop_ns(void *p)
> {
>         struct net *ns = p;
>         if (ns && atomic_dec_and_test(&ns->passive))
>                 net_free(ns);
> }
>
> Actually, I think it would be better to make this check before
> net_alloc().

You are probably right.  I seem to be trying to be entirely too clever
putting that in setup_net so I can cover the initial network namespace.
Which really does not need to be counted.  As clearly I also goofed up
the decrement on error case as well.

Eric
