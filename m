From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/6] Add support for offloading
 packet-sampling
Date: Thu, 13 Oct 2016 10:48:57 +0200
Message-ID: <20161013084857.GC1816@nanopsycho.orion>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us>
 <57FF37F5.4070100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34702 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752528AbcJMItA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 04:49:00 -0400
Received: by mail-lf0-f68.google.com with SMTP id x23so5765806lfi.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 01:48:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57FF37F5.4070100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 13, 2016 at 09:29:57AM CEST, roopa@cumulusnetworks.com wrote:
>On 10/12/16, 5:41 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Add the sample tc action, which allows to sample packet matching
>> a classifier. The sample action peeks randomly packets, duplicates them,
>> truncates them and adds informative metadata on the packet, for example,
>> the input interface and the original packet length. The sampled packets
>> are marked to allow matching them and redirecting them to a specific
>> collector device.
>>
>> The sampled packets metadata is packed using ife encapsulation. To do
>> that, this patch-set extracts ife logics from the tc_ife action into an
>> independent ife module, and uses that functionality to pack the metadata.
>> To include all the needed metadata, this patch-set introduces some new
>> IFE_META tlv types.
>>
>> In addition, Add the support for offloading the matchall-sample tc command
>> in the Mellanox mlxsw driver, for ingress qdiscs.
>>
>> Yotam Gigi (6):
>>   Introduce ife encapsulation module
>>   act_ife: Change to use ife module
>>   ife: Introduce new metadata tlv types
>>   Introduce sample tc action
>>   mlxsw: reg: add the Monitoring Packet Sampling Configuration Register
>>   mlxsw: packet sample: Add packet sample offloading support
>>
>
>we spoke with yotam about this at netdev1.2. and also remember speaking about this on our switchdev calls:
>Today our driver uses NFLOG to log packets to a netlink socket and hsflowd supported by the sflow
>people (at http://www.sflow.net/) is capable of reading from a nflog socket. NFLOG has the required netlink
>attribute markers for packet header/data (which we can possibly extend). We could also add nflog like action
>in tc if needed.
>
>sflow agents like hsflowd are capable of sending packets to an external collector with the required sflow header.
>Instead of re-inventing a new API for sflow, would be better to standardize/unify on existing mechanisms.
>
>Also, this patch series requires a new device to be created which can be avoided if we used
>existing mechanisms like NFLOG.

When I was first thinking about re-using NFLOG, it seemed like an
abusal. We need to call it from driver directly, which sounds odd.
However, since we use sample_packet_pack function to wrap it up, the
NFLOG is called from the tc action code, it does not look bad.
Yet still, this has nothing in common with netfilter, only using it's
log facilities. That is odd.

I think that the IFE ways is way more clear and generic and not-abusing.
However you are right the NFLOG way has advantage of existing user
component. I'm not sure how to do this :(
