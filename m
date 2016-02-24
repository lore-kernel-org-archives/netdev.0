From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Wed, 24 Feb 2016 08:09:43 -0500
Message-ID: <56CDAB97.1060505@mojatatu.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
 <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
 <CAM_iQpXb4=PP9=oNWH1vNHb81OGg7ivUtPaD8KfdQqVNYMKgoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>, dj@verizon.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33803 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbcBXNJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 08:09:47 -0500
Received: by mail-io0-f174.google.com with SMTP id 9so37446044iom.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 05:09:47 -0800 (PST)
In-Reply-To: <CAM_iQpXb4=PP9=oNWH1vNHb81OGg7ivUtPaD8KfdQqVNYMKgoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-23 04:44 PM, Cong Wang wrote:
> On Tue, Feb 23, 2016 at 4:49 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>> +#define MODULE_ALIAS_IFE_META(metan)   MODULE_ALIAS("ifemeta" __stringify_1(metan))
>> +
>> +int get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi);
>> +int get_meta_u16(struct sk_buff *skb, struct tcf_meta_info *mi);
>> +int tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval);
>> +int alloc_meta_u32(struct tcf_meta_info *mi, void *metaval);
>> +int alloc_meta_u16(struct tcf_meta_info *mi, void *metaval);
>> +int check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
>> +int encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info *mi);
>> +int validate_meta_u32(void *val, int len);
>> +int validate_meta_u16(void *val, int len);
>> +void release_meta_gen(struct tcf_meta_info *mi);
>> +int register_ife_op(struct tcf_meta_ops *mops);
>> +int unregister_ife_op(struct tcf_meta_ops *mops);
>
>
> These are exported to other modules, please add some prefix to protect them.
>

suggestion? I thought they seemed unique enough.


>> + * copyright   Jamal Hadi Salim (2015)
>
>
> 2016? ;)
>

Yes. This code has been around since then. Actually earlier than that
running. But i formatted it for kernel inclusion in about first week
of January. Dave asked me to wait for the ethertype to get it in.
The IETF still hasnt come through a year later and so i re-submitted
with no default ethertype. I think 2015 is deserving here, no?
I hope i dont spend another year discussing on the list ;-> /me runs

>

>> +               return 8;
>
>
> Why 8?
>

Magic number;-> I will add a comment.
It is a TLV that includes 4 bytes. I am going to wait for
comments to settle then make an update.

>> +

>> +
>> +int alloc_meta_u32(struct tcf_meta_info *mi, void *metaval)
>> +{
>> +       mi->metaval = kzalloc(sizeof(u32), GFP_KERNEL);
>> +       if (!mi->metaval)
>> +               return -ENOMEM;
>> +
>> +       memcpy(mi->metaval, metaval, 4);
>
>
> kmemdup()?
>

Sure. I'll take care of the rest you pointed to.

>


>
> No need to initi it since list_add_tail() is just one line below.
>
>
>> +       list_add_tail(&mops->list, &ifeoplist);
>> +       write_unlock(&ife_mod_lock);
>> +       return 0;
>> +}
>> +
>> +int unregister_ife_op(struct tcf_meta_ops *mops)
>> +{
>> +       struct tcf_meta_ops *m;
>> +       int err = -ENOENT;
>> +
>> +       write_lock(&ife_mod_lock);
>> +       list_for_each_entry(m, &ifeoplist, list) {
>> +               if (m->metaid == mops->metaid) {
>> +                       list_del(&mops->list);
>> +                       err = 0;
>> +                       break;
>> +               }
>> +       }
>> +       write_unlock(&ife_mod_lock);
>> +
>> +       return err;
>> +}
>> +
>> +EXPORT_SYMBOL_GPL(register_ife_op);
>> +EXPORT_SYMBOL_GPL(unregister_ife_op);
>
> Move them next to their definitions.
>
>
>> +
>> +void print_ife_oplist(void)
>> +{
>> +       struct tcf_meta_ops *o;
>> +       int i = 0;
>> +
>> +       read_lock(&ife_mod_lock);
>> +       list_for_each_entry(o, &ifeoplist, list) {
>> +               pr_debug("%d: %s metaid %d\n", ++i, o->name, o->metaid);
>> +       }
>> +       read_unlock(&ife_mod_lock);
>> +}
>> +
>> +/* called when adding new meta information
>> + * under ife->tcf_lock
>> +*/
>> +int load_metaops_and_vet(struct tcf_ife_info *ife, u32 metaid,
>> +                        void *val, int len)
>
>
> I failed to understand the name of this function.
>

It tries to load a metadata kernel module and vets (or validates)
the passed parameters from user space.
Suggestions?

>> +{
>> +       struct tcf_meta_ops *ops = find_ife_oplist(metaid);
>> +       int ret = 0;
>> +
>> +       if (!ops) {
>> +               ret = -ENOENT;
>> +#ifdef CONFIG_MODULES
>> +               spin_unlock_bh(&ife->tcf_lock);
>> +               rtnl_unlock();
>> +               request_module("ifemeta%u", metaid);
>> +               rtnl_lock();
>> +               spin_lock_bh(&ife->tcf_lock);
>> +               ops = find_ife_oplist(metaid);
>> +#endif
>> +       }
>> +
>> +       if (ops) {
>> +               ret = 0;
>> +
>> +               /* XXX: unfortunately cant use nla_policy at this point
>> +                * because a length of 0 is valid in the case of
>> +                * "allow". "use" semantics do enforce for proper
>> +                * length and i couldve use nla_policy but it makes it hard
>> +                * to use it just for that..
>> +                */
>> +               if (len) {
>> +                       if (ops->validate) {
>> +                               ret = ops->validate(val, len);
>> +                       } else {
>> +                               if (ops->metatype == NLA_U32) {
>> +                                       ret = validate_meta_u32(val, len);
>> +                               } else if (ops->metatype == NLA_U16) {
>> +                                       ret = validate_meta_u16(val, len);
>> +                               }
>> +                       }
>> +               }
>
>
> Sounds like this should be in a separated function.
>

Could be.


>> +int add_metainfo(struct tcf_ife_info *ife, u32 metaid, void *metaval, int len)
>> +{
>> +       struct tcf_meta_info *mi = NULL;
>> +       struct tcf_meta_ops *ops = find_ife_oplist(metaid);
>> +       int ret = 0;
>> +
>> +       if (!ops) {
>> +               return -ENOENT;
>> +       }
>> +
>> +       mi = kzalloc(sizeof(*mi), GFP_KERNEL);
>> +       if (!mi) {
>> +               /*put back what find_ife_oplist took */
>> +               module_put(ops->owner);
>> +               return -ENOMEM;
>> +       }
>> +
>> +       mi->metaid = metaid;
>> +       mi->ops = ops;
>> +       if (len > 0) {
>> +               ret = ops->alloc(mi, metaval);
>> +               if (ret != 0) {
>> +                       kfree(mi);
>> +                       module_put(ops->owner);
>> +                       return ret;
>> +               }
>> +       }
>> +
>> +       /*XXX: if it becomes necessary add per tcf_meta_info lock;
>> +        * for now use Thor's hammer */
>
>
> What about ife->tcf_lock?
>

I'll walk the code paths and check - it may be enough.

>
>> +       write_lock(&ife_mod_lock);
>> +       list_add_tail(&mi->metalist, &ife->metalist);
>> +       write_unlock(&ife_mod_lock);
>> +




>> +       if ((parm->flags & IFE_ENCODE) && (parm->flags & IFE_DECODE)) {
>> +               pr_info("Ambigous: Cant have both encode and decode\n");
>> +               return -EINVAL;
>> +       }
>
>
> Is it possible to fold them into one bit?

As in the check you mean?



>> +static struct tc_action_ops act_ife_ops = {
>> +       .kind = "ife",
>> +       .type = TCA_ACT_IFE,
>> +       .owner = THIS_MODULE,
>> +       .act = tcf_ife,
>> +       .dump = tcf_ife_dump,
>> +       .cleanup = tcf_ife_cleanup,
>> +       .init = tcf_ife_init,
>> +};
>> +
>> +static int __init ife_init_module(void)
>> +{
>> +       pr_info("Loaded IFE maximum metaid %d\n", max_metacnt);
>
>
> Not needed, people can use lsmod to figure it out.
>

Yeah - missed that one after Daniel's earlier comment.

>
>> +       INIT_LIST_HEAD(&ifeoplist);
>
> It is already initialized statically.


Good catch.


>> +module_param(max_metacnt, int, 0);
>
>
> I am sure DaveM doesn't like this.
>

You know what - i will take this thing out. Daniel doesnt like it
either.
Need to figure a different way to achieve the same goals.
Ok, when the noise settles i will make another release.

cheers,
jamal
