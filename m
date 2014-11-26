From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 09/17] bridge: add API to notify bridge
 driver of learned FBD on offloaded device
Date: Wed, 26 Nov 2014 09:16:41 +0100
Message-ID: <20141126081641.GB1875@nanopsycho.orion>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-10-git-send-email-jiri@resnulli.us>
 <54750669.4090406@gmail.com>
 <CAE4R7bBQnxKh7y+ViB-s-7b7Ro=gTQLavUTcNLA1u=3UJHa1Rg@mail.gmail.com>
 <54753C1F.1080109@gmail.com>
 <CAE4R7bCcB+HHDtULEdYA9uZUOtNJYL7edQQtfjh74wKQxxy-Lw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
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
	John Linville <linville@tu
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:49758 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbaKZIQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 03:16:43 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so11599825wiv.11
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 00:16:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCcB+HHDtULEdYA9uZUOtNJYL7edQQtfjh74wKQxxy-Lw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 26, 2014 at 03:40:59AM CET, sfeldma@gmail.com wrote:
>On Tue, Nov 25, 2014 at 4:34 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 25/11/14 18:03, Scott Feldman wrote:
>>> On Tue, Nov 25, 2014 at 12:44 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>>>> On 25/11/14 02:28, Jiri Pirko wrote:
>>>>> From: Scott Feldman <sfeldma@gmail.com>
>>>>>
>>>>> When the swdev device learns a new mac/vlan on a port, it sends some async
>>>>> notification to the driver and the driver installs an FDB in the device.
>>>>> To give a holistic system view, the learned mac/vlan should be reflected
>>>>> in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
>>>>> what is currently learned by the device.  This API on the bridge driver gives
>>>>> a way for the swdev driver to install an FBD entry in the bridge FBD table.
>>>>> (And remove one).
>>>>>
>>>>> This is equivalent to the device running these cmds:
>>>>>
>>>>>   bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
>>>>>
>>>>> This patch needs some extra eyeballs for review, in paricular around the
>>>>> locking and contexts.
>>>>>
>>>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>>> ---
>>>>
>>>> [snip]
>>>>
>>>>> +     head = &br->hash[br_mac_hash(addr, vid)];
>>>>> +     fdb = fdb_find(head, addr, vid);
>>>>> +     if (!fdb) {
>>>>> +             fdb = fdb_create(head, p, addr, vid);
>>>>> +             if (!fdb) {
>>>>> +                     err = -ENOMEM;
>>>>> +                     goto err_unlock;
>>>>> +             }
>>>>> +             fdb->added_by_external_learn = 1;
>>>>> +             fdb_notify(br, fdb, RTM_NEWNEIGH);
>>>>> +     } else if (fdb->added_by_external_learn) {
>>>>> +             /* Refresh entry */
>>>>> +             fdb->updated = fdb->used = jiffies;
>>>>> +     } else if (!fdb->added_by_user) {
>>>>> +             /* Take over SW learned entry */
>>>>> +             fdb->added_by_external_learn = 1;
>>>>> +             fdb->updated = jiffies;
>>>>> +             fdb_notify(br, fdb, RTM_NEWNEIGH);
>>>>> +     }
>>>>
>>>> Is there any case where this fdb entry gets re-used and is no longer
>>>> added by an external learning? Should we clear this flag somewhere?
>>>
>>> Once the FDB entry is marked "added_by_external_learn" it stays marked
>>> as such until removed by aging cleanup process (or flushed due to
>>> interface down, etc).  If aged out (and now deleted), the FDB entry
>>> may come back either by SW learn or by HW learn.  If SW learn comes
>>> first, and then HW learn, HW learn will override and mark the existing
>>> FDB entry "added_by_external_learn".  So there is take-over by HW but
>>> no give-back to SW.  And there is no explicit clearing of the mark
>>> short of deleting the FDB entry.  The mark is mostly for letting
>>> user's know which FDB entries where learned by HW and synced to the
>>> bridge's FDB.
>>
>> Thanks, makes sense now. This is probably obvious in this context, but
>> maybe it would not hurt to come up with a documentation that describe
>> the offload API, FDB entry lifetime and HW/SW ownership etc...
>
>I have an updated Documentation/networking/switchdev.txt that covers
>the swdev APIs and usage and notes, but Jiri is being stingy with it.

The doc update you mention includes also fib offload which we are not
pushing now. I have that patches in queue.

>Will get this out, either in v4 or follow-on patches.  There is enough
>going on just with L2 offload that we're going to need some good
>documentation to guide implementers.
