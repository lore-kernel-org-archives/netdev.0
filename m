From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: skip fdb add if the port
	shouldn't learn
Date: Thu, 4 Jun 2015 10:14:15 +0200
Message-ID: <CABQ03vHk+x=2J=Z2ZNk3M=p0hhrkAFeDK19A79Cq_mVX=U_a2w@mail.gmail.com>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
	<20150526102809.5c3e8abc@urahara>
	<CABQ03vEQhdXgWk5r103Yd0CPxEWuU3i0m8ztQjtgR0NFDbEXRQ@mail.gmail.com>
	<CAE4R7bBEn8Tvct_W0n7nR5YccEmTRByUc=-4nmvuQNqfrBFABg@mail.gmail.com>
	<CABQ03vEbgtHLyFmRs7ffpXGkTmjX9G=RbAhWwDrj-5rKysys5g@mail.gmail.com>
	<CAE4R7bDtY1jDcLnvEMx-y4U=SVvf867SPZc3vRjfrUYBA8W=0g@mail.gmail.com>
	<556DE481.5030201@cumulusnetworks.com>
	<CAE4R7bAU=ecvBrsK2J6DQQdL0OqgX_LUCQLp8cnBP4bk4HduQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, Wilson Kok <wkok@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAE4R7bAU=ecvBrsK2J6DQQdL0OqgX_LUCQLp8cnBP4bk4HduQg@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 3, 2015 at 7:57 AM, Scott Feldman <sfeldma@gmail.com> wrote:
> On Tue, Jun 2, 2015 at 10:14 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 5/27/15, 9:01 AM, Scott Feldman wrote:
>>>
>>> On Wed, May 27, 2015 at 1:35 AM, Nikolay Aleksandrov
>>> <nikolay@cumulusnetworks.com> wrote:
>>>>
>>>> On Wed, May 27, 2015 at 9:59 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>>>>>
>>>>> On Wed, May 27, 2015 at 12:05 AM, Nikolay Aleksandrov
>>>>> <nikolay@cumulusnetworks.com> wrote:
>>>>>>
>>>>>> On Tue, May 26, 2015 at 7:28 PM, Stephen Hemminger
>>>>>> <stephen@networkplumber.org> wrote:
>>>>>>>
>>>>>>> On Thu, 21 May 2015 03:42:57 -0700
>>>>>>> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>>>>>>>
>>>>>>>> From: Wilson Kok <wkok@cumulusnetworks.com>
>>>>>>>>
>>>>>>>> Check in fdb_add_entry() if the source port should learn, similar
>>>>>>>> check is used in br_fdb_update.
>>>>>>>> Note that new fdb entries which are added manually or
>>>>>>>> as local ones are still permitted.
>>>>>>>> This patch has been tested by running traffic via a bridge port and
>>>>>>>> switching the port's state, also by manually adding/removing entries
>>>>>>>> from the bridge's fdb.
>>>>>>>>
>>>>>>>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>>>>>>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>>>>>
>>>>>>> What is the problem this is trying to solve?
>>>>>>>
>>>>>>> I think user should be allowed to manually add any entry
>>>>>>> even if learning.
>>>>>>
>>>>>> Hi Stephen,
>>>>>> I have been thinking about the use case and have discussed it
>>>>>> internally with colleagues and the patch
>>>>>> author, the main problem is when there's an external software that
>>>>>> adds dynamic entries (learning) and
>>>>>> it could experience a race condition, here's a possible situation:
>>>>>> * external software learns a mac from hw, sends an add to kernel
>>>>>>   * right before that, port goes blocking (or down) and kernel flushes
>>>>>>     mac, sends notification about the state change and mac flush
>>>>>>   * right after that, kernel gets the previous add from external
>>>>>> software, it's
>>>>>>     allowed to add, and then sends an add notification
>>>>>>   * mean while, external software processes the link block/down and mac
>>>>>> flush,
>>>>>>     followed by the mac add from kernel.  At this point, external
>>>>>> software can't
>>>>>>     really know whether it's a user adding the mac intentionally or
>>>>>> it's
>>>>>>     a race.
>>>>>>
>>>>>> This issue can't really be avoided in user-space.
>>>>>> As I've noted local and static entries are still allowed, and iproute2
>>>>>> bridge utility always
>>>>>> marks the entries as static (NUD_NOARP), this only affects external
>>>>>> dynamic entries which
>>>>>> are usually sent by something that does the learning externally.
>>>>>> I'll keep digging to see if there's another way to go about this since
>>>>>> I'd like to give the user
>>>>>> full freedom. Personally I don't have strong feeling for this patch
>>>>>> and if it's not preferred then
>>>>>> I'll post a revert.
>>>>>
>>>>> So there is already a switchdev API to add/del an externally learned
>>>>> FDB entry which holds rtnl_lock and avoids these races.  I would
>>>>> suggest using that and revert this patch.
>>>>>
>>>>> See call_switchdev_notifiers(SWITCHDEV_FDB_ADD|SWITCHDEV_FDB_DEL) and
>>>>> the handler in br.c:br_switchdev_event().
>>>>>
>>>>> -scott
>>>>
>>>> Hmm, I'm new to the switchdev API and am possibly missing something,
>>>> but how do you suggest to use it here ?
>>>
>>> You need to call
>>> call_switchdev_notifiers(SWITCHDEV_FDB_ADD|SWITCHDEV_FDB_DEL) when the
>>> device learns a new mac/vlan on the port interface.
>>>
>>>> How can we differentiate between user-added entry and an externally
>>>> learned one ?
>>>
>>> Externally added ones will be marked with NTF_EXT_LEARNED set in
>>> ndm->ndm_flags in the netlink echo.  Manually added ones from the user
>>> will have ndm->ndm_state set to NUD_NOARP in the netlink echo.
>>>
>>>> Do you mean to use (for example) the NTF_EXT_LEARNED flag when adding
>>>> an entry from user-space so
>>>> the API can get called in br_fdb_add ?
>>>
>>> No.  br_fdb_add is the bridge's .ndo_fdb_add handler called when user
>>> manually adds an FDB entry using netlink RTM_NEWNEIGH.  For externally
>>> learned entries, use the internal
>>> call_switchdev_notifiers(SWITCHDEV_FDB_ADD|SWITCHDEV_FDB_DEL).
>>
>>
>> scott, I am assuming you are ok with an external learning entity (user space
>> driver or a controller) pushing entries
>> with the NTF_EXT_LEARNED correct ?. Because NTF_EXT_LEARNED is in uapi (and
>> analogous to RTNH_F_OFFLOAD in the fib offload world IMO)
>
> That seems OK.  I can see how that would remove the need for this
> patch, but still give you the control from user space daemon/listener
> to figure out what happened.

Hi,
I've been working on that but it doesn't really solve the problem
entirely because we still can get the
same race condition for the replace/modify case.
The reason is we have 2 choices:
1. Keep the flag permanent when an entry is created(learned) with it
 - This seems like the proper way since the entry was learned
externally somehow and that won't change

2. Modify the flag upon user change
 - I don't like this because it breaks the meaning and the consistency.

Thus we still cannot distinguish between user-generated request for
such entry and an external learning
process modifying it in the situation I gave in the beginning.
The more we discuss this patch internally, the more I'm actually
convinced it's correct because any
external learning entity (be it SDK, or some other software that adds
entries) should get an error when
trying to add/modify a dynamic (learned) entry for a port which
shouldn't learn. The same applies for
the entries that are learned via br_fdb_update, and that's why a
similar check is present there.
I think we should keep the patch, the new behaviour is justified.

Cheers,
 Nik
