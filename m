From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv4 net-next 09/10] openvswitch: Allow matching on conntrack label
Date: Wed, 19 Aug 2015 16:04:10 -0700
Message-ID: <CANr6G5yp1cj6GuhXDU6jvpaYAzb20-aiTUrpPLrBQAStwxpDVA@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
 <1439941188-19293-10-git-send-email-joestringer@nicira.com> <CALnjE+qVd=7ZdHXvVmOcHSEcFN2RxNrSwB7bck5=8P4oxdRnew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnjE+qVd=7ZdHXvVmOcHSEcFN2RxNrSwB7bck5=8P4oxdRnew@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the review,

On 19 August 2015 at 14:24, Pravin Shelar <pshelar@nicira.com> wrote:
> On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com=
> wrote:
>> Allow matching and setting the conntrack label field. As with ct_mar=
k,
>> this is populated by executing the CT action, and is a writable fiel=
d.
>> Specifying a label and optional mask allows the label to be modified=
,
>> which takes effect on the entry found by the lookup of the CT action=
=2E
>>
>> E.g.: actions:ct(zone=3D1,label=3D1)
>>
>> This will perform conntrack lookup in zone 1, then modify the label =
for
>> that entry. The conntrack entry itself must be committed using the
>> "commit" flag in the conntrack action flags for this change to persi=
st.
>>
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> I got compilation error after applying this patch:
> net/openvswitch/conntrack.c: In function =E2=80=98ovs_ct_init=E2=80=99=
:
> net/openvswitch/conntrack.c:713: error: expected =E2=80=98)=E2=80=99 =
before =E2=80=98;=E2=80=99 token
> net/openvswitch/conntrack.c:715: error: expected expression before =E2=
=80=98}=E2=80=99 token

Sorry about that, missed it in my final refactoring round. I'll fix thi=
s.

>>                                   type);
>> @@ -432,6 +521,10 @@ bool ovs_ct_verify(enum ovs_key_attr attr)
>>         if (attr & OVS_KEY_ATTR_CT_MARK)
>>                 return true;
>>  #endif
>> +#ifdef CONFIG_NF_CONNTRACK_LABELS
>> +       if (attr & OVS_KEY_ATTR_CT_LABEL)
>> +               return true;
>> +#endif
>>
> OVS_KEY_ATTR_CT_LABEL is not bit field so bitwise AND operation does
> not work here. This applies to all check done in this function.

Should be BIT(...), I'll fix this.

>>         return false;
>>  }
>> @@ -508,8 +601,12 @@ void ovs_ct_free_action(const struct nlattr *a)
>>
>>  void ovs_ct_init(struct net *net, struct ovs_ct_perdp_data *data)
>>  {
>> +       unsigned int n_bits =3D sizeof(struct ovs_key_ct_label) * BI=
TS_PER_BYTE;
>> +
>>         data->xt_v4 =3D !nf_ct_l3proto_try_module_get(PF_INET);
>>         data->xt_v6 =3D !nf_ct_l3proto_try_module_get(PF_INET6);
>> +       if (nf_connlabels_get(net, n_bits);
>> +               OVS_NLERR(true, "Failed to set connlabel length");
>>  }
>>
> In case of error should we reject conntrack label actions? Otherwise
> user will never see any error. But action could drop packets.

I suspect that currently errors would be seen from ovs_ct_set_label():

>.......if (!cl || cl->words * sizeof(long) < OVS_CT_LABEL_LEN)
>.......>.......return -ENOSPC;

So, for cmd_execute, userspace would see this. For regular handling,
pipeline processing would stop (so, drop).

However, I agree it would be more friendly to have the attribute
rejected up-front. Just means we'll pass the datapath all the way
down:
ovs_nla_get_match()
--> ovs_key_from_nlattrs()
--> metadata_from_nlattrs()
--> ovs_ct_verify()

And rather than simply reporting the error in ovs_ct_init() there,
we'll store the success condition something like:

@@ -721,8 +721,12 @@ void ovs_ct_init(struct net *net, struct
ovs_ct_perdp_data *data)

        data->xt_v4 =3D !nf_ct_l3proto_try_module_get(PF_INET);
        data->xt_v6 =3D !nf_ct_l3proto_try_module_get(PF_INET6);
-       if (nf_connlabels_get(net, n_bits));
+       if (nf_connlabels_get(net, n_bits)) {
+               data->xt_label =3D false;
                OVS_NLERR(true, "Failed to set connlabel length");
+       } else {
+               data->xt_label =3D true;
+       }
 }

 void ovs_ct_exit(struct net *net, struct ovs_ct_perdp_data *data)

ovs_ct_exit() also needs to be updated to ensure that if this fails,
we don't try to put the connlabel use back.
