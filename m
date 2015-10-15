From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 3/3] openvswitch: Serialize nested ct actions if provided
Date: Thu, 15 Oct 2015 11:13:39 -0700
Message-ID: <CALnjE+qYzaGgxrM5KZWdWRiER213r_ja3iZh+PO+3fbXwi6BEg@mail.gmail.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
	<1444846249-52053-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33588 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbbJOSNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 14:13:40 -0400
Received: by iodv82 with SMTP id v82so98868275iod.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 11:13:39 -0700 (PDT)
In-Reply-To: <1444846249-52053-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 11:10 AM, Joe Stringer <joestringer@nicira.com> wrote:
> If userspace provides a ct action with no nested mark or label, then the
> storage for these fields is zeroed. Later when actions are requested,
> such zeroed fields are serialized even though userspace didn't
> originally specify them. Fix the behaviour by ensuring that no action is
> serialized in this case, and reject actions where userspace attempts to
> set these fields with mask=0. This should make netlink marshalling
> consistent across deserialization/reserialization.
>
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
>  net/openvswitch/conntrack.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 480dbb9095b7..ba29e6c2e0d4 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -540,6 +540,16 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
>         return 0;
>  }
>
> +static bool label_zero(const struct ovs_key_ct_labels *labels)
> +{
> +       int i;
> +
> +       for (i = 0; i < sizeof(*labels); i++)
> +               if (labels->ct_labels[i])
> +                       return false;
> +       return true;
> +}
> +
There is already function called labels_nonzero(), This can be reused
for labels check.


>  static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
>         [OVS_CT_ATTR_COMMIT]    = { .minlen = 0, .maxlen = 0 },
>         [OVS_CT_ATTR_ZONE]      = { .minlen = sizeof(u16),
> @@ -589,6 +599,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
>                 case OVS_CT_ATTR_MARK: {
>                         struct md_mark *mark = nla_data(a);
>
> +                       if (!mark->mask) {
> +                               OVS_NLERR(log, "ct_mark mask cannot be 0");
> +                               return -EINVAL;
> +                       }
>                         info->mark = *mark;
>                         break;
>                 }
> @@ -597,6 +611,10 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
>                 case OVS_CT_ATTR_LABELS: {
>                         struct md_labels *labels = nla_data(a);
>
> +                       if (label_zero(&labels->mask)) {
> +                               OVS_NLERR(log, "ct_labels mask cannot be 0");
> +                               return -EINVAL;
> +                       }

After this flow install stage sanity check for labels, there is no
need for check in CONFIG_NF_CONNTRACK_LABELS action execution.
