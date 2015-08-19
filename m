From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv4 net-next 10/10] openvswitch: Allow attaching helpers to
 ct action
Date: Wed, 19 Aug 2015 15:57:40 -0700
Message-ID: <CALnjE+p7WH53qx4=OBpFAT-CDRMbuUx1c_RspQYqBdBbG1=LjA@mail.gmail.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
	<1439941188-19293-11-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439941188-19293-11-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2015 at 4:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Add support for using conntrack helpers to assist protocol detection.
> The new OVS_CT_ATTR_HELPER attribute of the ct action specifies a helper
> to be used for this connection.
>
> Example ODP flows allowing FTP connections from ports 1->2:
> in_port=1,tcp,action=ct(helper=ftp,commit),2
> in_port=2,tcp,ct_state=-trk,action=ct(),recirc(1)
> recirc_id=1,in_port=2,tcp,ct_state=+trk-new+est,action=1
> recirc_id=1,in_port=2,tcp,ct_state=+trk+rel,action=1
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2-v3: No change.
> v4: Change error code for unknown helper ENOENT->EINVAL.

I got following compilation warning :

net/openvswitch/conntrack.c:352:42: error: incompatible types in
comparison expression (different address spaces)

> ---
>  include/uapi/linux/openvswitch.h |   3 ++
>  net/openvswitch/conntrack.c      | 109 ++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 110 insertions(+), 2 deletions(-)
>
...

> +static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
> +                            const struct sw_flow_key *key, bool log)
> +{
> +       struct nf_conntrack_helper *helper;
> +       struct nf_conn_help *help;
> +
> +       helper = nf_conntrack_helper_try_module_get(name, info->family,
> +                                                   key->ip.proto);
> +       if (!helper) {
> +               OVS_NLERR(log, "Unknown helper \"%s\"", name);
> +               return -EINVAL;
> +       }
> +
> +       help = nf_ct_helper_ext_add(info->ct, helper, GFP_KERNEL);
> +       if (!help) {
> +               module_put(helper->me);
> +               return -ENOMEM;
> +       }
> +
> +       help->helper = helper;
helper is rcu pointer so need to use rcu API to set the value. I know
it is not required here, but it is still cleaner to use the API.

> +       info->helper = helper;
> +       return 0;
> +}
> +
