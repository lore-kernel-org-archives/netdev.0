From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/5] vxlan: support fdb and learning in COLLECT_METADATA
 mode
Date: Tue, 31 Jan 2017 19:38:28 -0800
Message-ID: <58915834.9080802@cumulusnetworks.com>
References: <1485842235-32343-1-git-send-email-roopa@cumulusnetworks.com> <1485842235-32343-3-git-send-email-roopa@cumulusnetworks.com> <7e4844ec-df5e-6140-c2f7-281619616416@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        tgraf@suug.ch, hannes@stressinduktion.org, jbenc@redhat.com,
        pshelar@ovn.org, dsa@cumulusnetworks.com, hadi@mojatatu.com
To: jtoppins@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35618 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdBADih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 22:38:37 -0500
Received: by mail-pf0-f174.google.com with SMTP id f144so114905687pfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 19:38:37 -0800 (PST)
In-Reply-To: <7e4844ec-df5e-6140-c2f7-281619616416@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/17, 3:37 PM, Jonathan Toppins wrote:
> On 01/31/2017 12:57 AM, Roopa Prabhu wrote:
[snip]
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 19b1653..b80c405 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -57,6 +57,8 @@
>>  
>>  static const u8 all_zeros_mac[ETH_ALEN + 2];
>>  
>> +static u32 fdb_salt __read_mostly;
>> +
>>  static int vxlan_sock_add(struct vxlan_dev *vxlan);
>>  
>>  /* per-network namespace private data for this module */
>> @@ -75,6 +77,7 @@ struct vxlan_fdb {
>>  	struct list_head  remotes;
>>  	u8		  eth_addr[ETH_ALEN];
>>  	u16		  state;	/* see ndm_state */
>> +	__be32		  vni;
>>  	u8		  flags;	/* see ndm_flags */
>>  };
>>  
>> @@ -302,6 +305,10 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
>>  	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
>>  	    nla_put_u32(skb, NDA_VNI, be32_to_cpu(rdst->remote_vni)))
>>  		goto nla_put_failure;
>> +	if ((vxlan->flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
>> +	    nla_put_u32(skb, NDA_SRC_VNI,
>> +			be32_to_cpu(fdb->vni)))
>> +		goto nla_put_failure;
>>  	if (rdst->remote_ifindex &&
>>  	    nla_put_u32(skb, NDA_IFINDEX, rdst->remote_ifindex))
>>  		goto nla_put_failure;
>> @@ -400,34 +407,51 @@ static u32 eth_hash(const unsigned char *addr)
>>  	return hash_64(value, FDB_HASH_BITS);
>>  }
>>  
>> +static u32 eth_vni_hash(const unsigned char *addr, __be32 vni)
>> +{
>> +	/* use 1 byte of OUI and 3 bytes of NIC */
>> +	u32 key = get_unaligned((u32 *)(addr + 2));
>> +
>> +	return jhash_2words(key, vni, fdb_salt) & (FDB_HASH_SIZE - 1);
> Not seeing where fdb_salt gets set to anything, why not just use a
> constant zero here?
>
>
oversight. intended to use vxlan_salt which is already initialized but not used in the vxlan driver.
 fixed in next queued up version (just following bridge fdb code here which uses salt).

thanks.
