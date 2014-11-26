From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 25 Nov 2014 18:34:07 -0800
Message-ID: <54753C1F.1080109@gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>	<1416911328-10979-10-git-send-email-jiri@resnulli.us>	<54750669.4090406@gmail.com> <CAE4R7bBQnxKh7y+ViB-s-7b7Ro=gTQLavUTcNLA1u=3UJHa1Rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:41115 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaKZCeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:34:11 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so1867610pab.2
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:34:10 -0800 (PST)
In-Reply-To: <CAE4R7bBQnxKh7y+ViB-s-7b7Ro=gTQLavUTcNLA1u=3UJHa1Rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/11/14 18:03, Scott Feldman wrote:
> On Tue, Nov 25, 2014 at 12:44 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 25/11/14 02:28, Jiri Pirko wrote:
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> When the swdev device learns a new mac/vlan on a port, it sends some async
>>> notification to the driver and the driver installs an FDB in the device.
>>> To give a holistic system view, the learned mac/vlan should be reflected
>>> in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
>>> what is currently learned by the device.  This API on the bridge driver gives
>>> a way for the swdev driver to install an FBD entry in the bridge FBD table.
>>> (And remove one).
>>>
>>> This is equivalent to the device running these cmds:
>>>
>>>   bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
>>>
>>> This patch needs some extra eyeballs for review, in paricular around the
>>> locking and contexts.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>
>> [snip]
>>
>>> +     head = &br->hash[br_mac_hash(addr, vid)];
>>> +     fdb = fdb_find(head, addr, vid);
>>> +     if (!fdb) {
>>> +             fdb = fdb_create(head, p, addr, vid);
>>> +             if (!fdb) {
>>> +                     err = -ENOMEM;
>>> +                     goto err_unlock;
>>> +             }
>>> +             fdb->added_by_external_learn = 1;
>>> +             fdb_notify(br, fdb, RTM_NEWNEIGH);
>>> +     } else if (fdb->added_by_external_learn) {
>>> +             /* Refresh entry */
>>> +             fdb->updated = fdb->used = jiffies;
>>> +     } else if (!fdb->added_by_user) {
>>> +             /* Take over SW learned entry */
>>> +             fdb->added_by_external_learn = 1;
>>> +             fdb->updated = jiffies;
>>> +             fdb_notify(br, fdb, RTM_NEWNEIGH);
>>> +     }
>>
>> Is there any case where this fdb entry gets re-used and is no longer
>> added by an external learning? Should we clear this flag somewhere?
> 
> Once the FDB entry is marked "added_by_external_learn" it stays marked
> as such until removed by aging cleanup process (or flushed due to
> interface down, etc).  If aged out (and now deleted), the FDB entry
> may come back either by SW learn or by HW learn.  If SW learn comes
> first, and then HW learn, HW learn will override and mark the existing
> FDB entry "added_by_external_learn".  So there is take-over by HW but
> no give-back to SW.  And there is no explicit clearing of the mark
> short of deleting the FDB entry.  The mark is mostly for letting
> user's know which FDB entries where learned by HW and synced to the
> bridge's FDB.

Thanks, makes sense now. This is probably obvious in this context, but
maybe it would not hurt to come up with a documentation that describe
the offload API, FDB entry lifetime and HW/SW ownership etc...

> 
>> [snip]
>>
>>> +EXPORT_SYMBOL(br_fdb_external_learn_del);
>>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>>> index 4f577c4..02cd63b 100644
>>> --- a/net/bridge/br_private.h
>>> +++ b/net/bridge/br_private.h
>>> @@ -101,6 +101,7 @@ struct net_bridge_fdb_entry
>>>       unsigned char                   is_local;
>>>       unsigned char                   is_static;
>>>       unsigned char                   added_by_user;
>>> +     unsigned char                   added_by_external_learn;
>>
>> Pheww, we could be saving some memory footprint here by using different
>> types here ;)
>> --
>> Florian
