From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Fri, 9 Dec 2016 11:49:24 +0100
Message-ID: <CACT4Y+beWN9jmdTREk3JdEBQ3GRALGDJhy7pYF=wu3HdnNWEog@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca> <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca> <20161209060248.GT22655@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-audit@redhat.com,
        pmoore@redhat.com, David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209060248.GT22655@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 9, 2016 at 7:02 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 2016-11-29 23:52, Richard Guy Briggs wrote:
>> On 2016-11-29 15:13, Cong Wang wrote:
>> > On Tue, Nov 29, 2016 at 8:48 AM, Richard Guy Briggs <rgb@redhat.com> w=
rote:
>> > > On 2016-11-26 17:11, Cong Wang wrote:
>> > >> It is racy on audit_sock, especially on the netns exit path.
>> > >
>> > > I think that is the only place it is racy.  The other places audit_s=
ock
>> > > is set is when the socket failure has just triggered a reset.
>> > >
>> > > Is there a notifier callback for failed or reaped sockets?
>> >
>> > Is NETLINK_URELEASE event what you are looking for?
>>
>> Possibly, yes.  Thanks, I'll have a look.
>
> I tried a quick compile attempt on the test case (I assume it is a
> socket fuzzer) and get the following compile error:
> cc -g -O0 -Wall -D_GNU_SOURCE -o socket_fuzz socket_fuzz.c
> socket_fuzz.c:16:1: warning: "_GNU_SOURCE" redefined
> <command-line>: warning: this is the location of the previous definition
> socket_fuzz.c: In function =E2=80=98segv_handler=E2=80=99:
> socket_fuzz.c:89: warning: implicit declaration of function =E2=80=98__at=
omic_load_n=E2=80=99
> socket_fuzz.c:89: error: =E2=80=98__ATOMIC_RELAXED=E2=80=99 undeclared (f=
irst use in this function)
> socket_fuzz.c:89: error: (Each undeclared identifier is reported only onc=
e
> socket_fuzz.c:89: error: for each function it appears in.)
> socket_fuzz.c: In function =E2=80=98loop=E2=80=99:
> socket_fuzz.c:280: warning: unused variable =E2=80=98errno0=E2=80=99
> socket_fuzz.c: In function =E2=80=98test=E2=80=99:
> socket_fuzz.c:303: warning: implicit declaration of function =E2=80=98__a=
tomic_fetch_add=E2=80=99
> socket_fuzz.c:303: error: =E2=80=98__ATOMIC_SEQ_CST=E2=80=99 undeclared (=
first use in this function)
> socket_fuzz.c:303: warning: implicit declaration of function =E2=80=98__a=
tomic_fetch_sub=E2=80=99

-std=3Dgnu99 should help
ignore warnings



> I also tried to extend Cong Wang's idea to attempt to proactively respond=
 to a
> NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking e=
rror
> stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
> Eliminating the lock since the sock is dead anways eliminates the error.
>
> Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll t=
ry to
> get the test case to compile.
>
> This is being tracked as https://github.com/linux-audit/audit-kernel/issu=
es/30
>
> Subject: [PATCH] audit: proactively reset audit_sock on matching NETLINK_=
URELEASE
>
> diff --git a/kernel/audit.c b/kernel/audit.c
> index f1ca116..91d222d 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -423,6 +423,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
>                                 snprintf(s, sizeof(s), "audit_pid=3D%d re=
set", audit_pid);
>                                 audit_log_lost(s);
>                                 audit_pid =3D 0;
> +                               audit_nlk_portid =3D 0;
>                                 audit_sock =3D NULL;
>                         } else {
>                                 pr_warn("re-scheduling(#%d) write to audi=
t_pid=3D%d\n",
> @@ -1143,6 +1144,28 @@ static int audit_bind(struct net *net, int group)
>         return 0;
>  }
>
> +static int audit_sock_netlink_notify(struct notifier_block *nb,
> +                                    unsigned long event,
> +                                    void *_notify)
> +{
> +       struct netlink_notify *notify =3D _notify;
> +       struct audit_net *aunet =3D net_generic(notify->net, audit_net_id=
);
> +
> +       if (event =3D=3D NETLINK_URELEASE && notify->protocol =3D=3D NETL=
INK_AUDIT) {
> +               if (audit_nlk_portid =3D=3D notify->portid &&
> +                   audit_sock =3D=3D aunet->nlsk) {
> +                       audit_pid =3D 0;
> +                       audit_nlk_portid =3D 0;
> +                       audit_sock =3D NULL;
> +               }
> +       }
> +       return NOTIFY_DONE;
> +}
> +
> +static struct notifier_block audit_netlink_notifier =3D {
> +       .notifier_call =3D audit_sock_netlink_notify,
> +};
> +
>  static int __net_init audit_net_init(struct net *net)
>  {
>         struct netlink_kernel_cfg cfg =3D {
> @@ -1167,10 +1190,14 @@ static void __net_exit audit_net_exit(struct net =
*net)
>  {
>         struct audit_net *aunet =3D net_generic(net, audit_net_id);
>         struct sock *sock =3D aunet->nlsk;
> +
> +       mutex_lock(&audit_cmd_mutex);
>         if (sock =3D=3D audit_sock) {
>                 audit_pid =3D 0;
> +               audit_nlk_portid =3D 0;
>                 audit_sock =3D NULL;
>         }
> +       mutex_unlock(&audit_cmd_mutex);
>
>         RCU_INIT_POINTER(aunet->nlsk, NULL);
>         synchronize_net();
> @@ -1202,6 +1229,7 @@ static int __init audit_init(void)
>         audit_enabled =3D audit_default;
>         audit_ever_enabled |=3D !!audit_default;
>
> +       netlink_register_notifier(&audit_netlink_notifier);
>         audit_log(NULL, GFP_KERNEL, AUDIT_KERNEL, "initialized");
>
>         for (i =3D 0; i < AUDIT_INODE_BUCKETS; i++)
> --
> 1.7.1
>
>
>> - RGB
>
> - RGB
>
> --
> Richard Guy Briggs <rgb@redhat.com>
> Kernel Security Engineering, Base Operating Systems, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635
