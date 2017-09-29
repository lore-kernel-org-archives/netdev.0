From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [patch net-next 1/7] skbuff: Add the offload_mr_fwd_mark field
Date: Fri, 29 Sep 2017 13:14:46 +0200
Message-ID: <1506683686.2980.44.camel@redhat.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
         <20170928173415.15551-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, pabeni@redhat.com, daniel@iogearbox.net,
        f.fainelli@gmail.com, fw@strlen.de, gfree.wind@vip.163.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751667AbdI2LOv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 07:14:51 -0400
In-Reply-To: <20170928173415.15551-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello Jiri and Yotam,

On Thu, 2017-09-28 at 19:34 +0200, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 19e64bf..ada8214 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -772,6 +772,7 @@ struct sk_buff {
>  	__u8			remcsum_offload:1;
>  #ifdef CONFIG_NET_SWITCHDEV
>  	__u8			offload_fwd_mark:1;
> +	__u8			offload_mr_fwd_mark:1;

I had a look at the pahole output:

$ make allyesconfig
$ make net/core/skbuff.o
$ pahole net/core/skbuff.o | grep -C7 tc_from_ingress


        __u8                       ipvs_property:1;      /*   147: 7  1 */
        __u8                       inner_protocol_type:1; /*   147: 6  1 */
        __u8                       remcsum_offload:1;    /*   147: 5  1 */
        __u8                       offload_fwd_mark:1;   /*   147: 4  1 */
        __u8                       tc_skip_classify:1;   /*   147: 3  1 */
        __u8                       tc_at_ingress:1;      /*   147: 2  1 */
        __u8                       tc_redirected:1;      /*   147: 1  1 */
        __u8                       tc_from_ingress:1;    /*   147: 0  1 */
        __u16                      tc_index;             /*   148     2 */

        /* XXX 2 bytes hole, try to pack */

        union {
                __wsum             csum;                 /*           4 */
                struct {

apparently there are no more spare bits to use at that offset: therefore,
adding 'offload_mr_fwd_mark' before 'tc_skip_classify' will make
'tc_from_ingress' slip at offset 148, and tc_index at offset 150.
I think you can use that 2-bytes hole below tc_index, and also move the
offload_fwd_mark bit there, as we use both when CONFIG_NET_SWITCHDEV is
enabled. This way we will also gain one spare bit, without changing the
struct size or worsening the cacheline alignments.

what do you think?

regards,
-- 
davide
