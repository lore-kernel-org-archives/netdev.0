From: Andrei Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 09/10] netns: Add a limit on the number of net
	namespaces
Date: Mon, 25 Jul 2016 23:01:19 -0700
Message-ID: <CANaxB-zfkvu9XYkuYB47tYFGLeVnWBhpgEUaSrGD4+-O8ThcNw@mail.gmail.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
	<20160721164014.17534-1-ebiederm@xmission.com>
	<20160721164014.17534-9-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160721164014.17534-9-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Thu, Jul 21, 2016 at 9:40 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  include/linux/user_namespace.h |  1 +
>  kernel/user_namespace.c        |  1 +
>  net/core/net_namespace.c       | 15 +++++++++++++++
>  3 files changed, 17 insertions(+)
>
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 1a3a9cb93277..f86afa536baf 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -27,6 +27,7 @@ enum ucounts {
>         UCOUNT_PID_NAMESPACES,
>         UCOUNT_UTS_NAMESPACES,
>         UCOUNT_IPC_NAMESPACES,
> +       UCOUNT_NET_NAMESPACES,
>         UCOUNT_CGROUP_NAMESPACES,
>         UCOUNT_COUNTS,
>  };
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 1cf074cb47e2..e326ca722ae0 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -80,6 +80,7 @@ static struct ctl_table userns_table[] = {
>         UCOUNT_ENTRY("max_pid_namespaces"),
>         UCOUNT_ENTRY("max_uts_namespaces"),
>         UCOUNT_ENTRY("max_ipc_namespaces"),
> +       UCOUNT_ENTRY("max_net_namespaces"),
>         UCOUNT_ENTRY("max_cgroup_namespaces"),
>         { }
>  };
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 2c2eb1b629b1..a489f192d619 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -266,6 +266,16 @@ struct net *get_net_ns_by_id(struct net *net, int id)
>         return peer;
>  }
>
> +static bool inc_net_namespaces(struct user_namespace *ns)
> +{
> +       return inc_ucount(ns, UCOUNT_NET_NAMESPACES);
> +}
> +
> +static void dec_net_namespaces(struct user_namespace *ns)
> +{
> +       dec_ucount(ns, UCOUNT_NET_NAMESPACES);
> +}
> +
>  /*
>   * setup_net runs the initializers for the network namespace object.
>   */
> @@ -276,6 +286,9 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
>         int error = 0;
>         LIST_HEAD(net_exit_list);
>
> +       if (!inc_net_namespaces(user_ns))
> +               return -ENFILE;

I think you need to move this check after initilizing  net->passive.
When setup_net returns an error, net_drop_ns is called:

void net_drop_ns(void *p)
{
        struct net *ns = p;
        if (ns && atomic_dec_and_test(&ns->passive))
                net_free(ns);
}

Actually, I think it would be better to make this check before net_alloc().

> +
>         atomic_set(&net->count, 1);
>         atomic_set(&net->passive, 1);
>         net->dev_base_seq = 1;
> @@ -372,6 +385,7 @@ struct net *copy_net_ns(unsigned long flags,
>         }
>         mutex_unlock(&net_mutex);
>         if (rv < 0) {
> +               dec_net_namespaces(user_ns);
>                 put_user_ns(user_ns);
>                 net_drop_ns(net);
>                 return ERR_PTR(rv);
> @@ -444,6 +458,7 @@ static void cleanup_net(struct work_struct *work)
>         /* Finally it is safe to free my network namespace structure */
>         list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
>                 list_del_init(&net->exit_list);
> +               dec_net_namespaces(net->user_ns);
>                 put_user_ns(net->user_ns);
>                 net_drop_ns(net);
>         }
> --
> 2.8.3
>
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
