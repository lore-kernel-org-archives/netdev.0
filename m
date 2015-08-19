From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv4 net-next 09/10] openvswitch: Allow matching on conntrack label
Date: Wed, 19 Aug 2015 14:24:54 -0700
Message-ID: <CALnjE+qVd=7ZdHXvVmOcHSEcFN2RxNrSwB7bck5=8P4oxdRnew@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
	<1439941188-19293-10-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439941188-19293-10-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com> =
wrote:
> Allow matching and setting the conntrack label field. As with ct_mark=
,
> this is populated by executing the CT action, and is a writable field=
=2E
> Specifying a label and optional mask allows the label to be modified,
> which takes effect on the entry found by the lookup of the CT action.
>
> E.g.: actions:ct(zone=3D1,label=3D1)
>
> This will perform conntrack lookup in zone 1, then modify the label f=
or
> that entry. The conntrack entry itself must be committed using the
> "commit" flag in the conntrack action flags for this change to persis=
t.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
I got compilation error after applying this patch:
net/openvswitch/conntrack.c: In function =E2=80=98ovs_ct_init=E2=80=99:
net/openvswitch/conntrack.c:713: error: expected =E2=80=98)=E2=80=99 be=
fore =E2=80=98;=E2=80=99 token
net/openvswitch/conntrack.c:715: error: expected expression before =E2=80=
=98}=E2=80=99 token

> ---
> v2: Split out setting the connlabel size for the current namespace.
> v3: No change.
> v4: Only allow setting label via ct action.
>     Update documentation.
> ---
=2E..
>                                   type);
> @@ -432,6 +521,10 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
>         if (attr & OVS_KEY_ATTR_CT_MARK)
>                 return true;
>  #endif
> +#ifdef CONFIG_NF_CONNTRACK_LABELS
> +       if (attr & OVS_KEY_ATTR_CT_LABEL)
> +               return true;
> +#endif
>
OVS_KEY_ATTR_CT_LABEL is not bit field so bitwise AND operation does
not work here. This applies to all check done in this function.

>         return false;
>  }
> @@ -508,8 +601,12 @@ void ovs_ct_free_action(const struct nlattr *a)
>
>  void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
>  {
> +       unsigned int n_bits =3D sizeof(struct ovs_key_ct_label) * BIT=
S_PER_BYTE;
> +
>         data->xt_v4 =3D !nf_ct_l3proto_try_module_get(PF_INET);
>         data->xt_v6 =3D !nf_ct_l3proto_try_module_get(PF_INET6);
> +       if (nf_connlabels_get(net, n_bits);
> +               OVS_NLERR(true, "Failed to set connlabel length");
>  }
>
In case of error should we reject conntrack label actions? Otherwise
user will never see any error. But action could drop packets.

>  void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)
> @@ -518,4 +615,5 @@ void ovs_ct_exit(struct net *net, struct ovs_ct_p=
erdp_data *data)
>                 nf_ct_l3proto_module_put(PF_INET);
>         if (data->xt_v6)
>                 nf_ct_l3proto_module_put(PF_INET6);
> +       nf_connlabels_put(net);
>  }
