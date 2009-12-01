From: Patrick McHardy <kaber@trash.net>
Subject: Re: net 03/05: fib_rules: add oif classification
Date: Tue, 01 Dec 2009 10:32:40 +0100
Message-ID: <4B14E2B8.3030507@trash.net>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175533.7555.35189.sendpatchset@x2.localnet> <4B1447DD.1070904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39030 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbZLAJcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 04:32:36 -0500
In-Reply-To: <4B1447DD.1070904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Patrick McHardy wrote, On 11/30/2009 06:55 PM:
>   
>> diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
>> index 62bebcb..d4e875a 100644
>> --- a/include/net/fib_rules.h
>> +++ b/include/net/fib_rules.h
>> @@ -11,6 +11,7 @@ struct fib_rule {
>>  	struct list_head	list;
>>  	atomic_t		refcnt;
>>  	int			iifindex;
>> +	int			oifindex;
>>     
>
> Doesn't it "break" the cacheline fix from 01/05?

No, there's a 4 byte hole which is plugged by this:

struct fib_rule {
        struct list_head           list;                 /*     0    16 */
        atomic_t                   refcnt;               /*    16     4 */
        int                        iifindex;             /*    20     4 */
        int                        oifindex;             /*    24     4 */
        u32                        mark;                 /*    28     4 */
        u32                        mark_mask;            /*    32     4 */
        u32                        pref;                 /*    36     4 */
        u32                        flags;                /*    40     4 */
        u32                        table;                /*    44     4 */
        u8                         action;               /*    48     1 */

        /* XXX 3 bytes hole, try to pack */

        u32                        target;               /*    52     4 */
        struct fib_rule *          ctarget;              /*    56     8 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        char                       iifname[16];          /*    64    16 */
        char                       oifname[16];          /*    80    16 */
        struct rcu_head            rcu;                  /*    96    16 */
        struct net *               fr_net;               /*   112     8 */
        /* size: 120, cachelines: 2 */
        /* sum members: 117, holes: 1, sum holes: 3 */
        /* last cacheline: 56 bytes */
};      /* definitions: 1 */


