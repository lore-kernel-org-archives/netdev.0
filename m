From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v8] net: openvswitch - set name assign type
Date: Thu, 17 Jul 2014 01:16:43 +0200
Message-ID: <CAG-2HqUY_mUDRjT6XrwX68FZvgvTVSzkbAOs-m9g3--ZhYQ5Kw@mail.gmail.com>
References: <1405550594-11786-1-git-send-email-teg@jklm.no>
 <1405550594-11786-3-git-send-email-teg@jklm.no> <CALnjE+oQ31p4KrMqwM2mPve76_xX2LEogP4QfOMYJ1+29m4txA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnjE+oQ31p4KrMqwM2mPve76_xX2LEogP4QfOMYJ1+29m4txA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 1:00 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Jul 16, 2014 at 3:43 PM, Tom Gundersen <teg@jklm.no> wrote:
>> Signed-off-by: Tom Gundersen <teg@jklm.no>
>> Cc: Pravin Shelar <pshelar@nicira.com>
>> Cc: dev@openvswitch.org
>> ---
>>
>> This patch goes on top of net-next.
>>
>>  net/openvswitch/datapath.c           | 1 +
>>  net/openvswitch/vport-internal_dev.c | 2 +-
>>  net/openvswitch/vport.h              | 2 ++
>>  3 files changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
>> index fe95b6c..c1400c0 100644
>> --- a/net/openvswitch/datapath.c
>> +++ b/net/openvswitch/datapath.c
>> @@ -1370,6 +1370,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
>>
>>         /* Set up our datapath device. */
>>         parms.name = nla_data(a[OVS_DP_ATTR_NAME]);
>> +       parms.name_assign_type = NET_NAME_USER;
>>         parms.type = OVS_VPORT_TYPE_INTERNAL;
>>         parms.options = NULL;
>>         parms.dp = dp;
>> diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
>> index bd65855..df185a7 100644
>> --- a/net/openvswitch/vport-internal_dev.c
>> +++ b/net/openvswitch/vport-internal_dev.c
>> @@ -165,7 +165,7 @@ static struct vport *internal_dev_create(const struct vport_parms *parms)
>>         netdev_vport = netdev_vport_priv(vport);
>>
>>         netdev_vport->dev = alloc_netdev(sizeof(struct internal_dev),
>> -                                        parms->name, NET_NAME_UNKNOWN,
>> +                                        parms->name, parms->name_assign_type,
>>                                          do_setup);
>>         if (!netdev_vport->dev) {
>>                 err = -ENOMEM;
>
> vport name is always configured by user. Therefore can you just
> replace NET_NAME_UNKNOWN with NET_NAME_USER while calling
> alloc_netdev().

I did it in this way to 1) make it trivial to review the patch without
necessarily knowing the code very well and 2) decrease the likelihood
of whomever changes these things in the future accidentally breaking
the labelling (e.g. by introducing a new caller of
internal_dev_create, which sets the ifname from a different source).

Your way would work to of course, let me know if I should redo it like that.

Cheers,

Tom

>> diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
>> index 8d721e6..a9d7480 100644
>> --- a/net/openvswitch/vport.h
>> +++ b/net/openvswitch/vport.h
>> @@ -97,6 +97,7 @@ struct vport {
>>   * struct vport_parms - parameters for creating a new vport
>>   *
>>   * @name: New vport's name.
>> + * @name_assign_type: New vport's name's origin.
>>   * @type: New vport's type.
>>   * @options: %OVS_VPORT_ATTR_OPTIONS attribute from Netlink message, %NULL if
>>   * none was supplied.
>> @@ -105,6 +106,7 @@ struct vport {
>>   */
>>  struct vport_parms {
>>         const char *name;
>> +       unsigned char name_assign_type;
>>         enum ovs_vport_type type;
>>         struct nlattr *options;
>>
>> --
>> 1.9.3
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
