From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH 2/3] bridge: trigger a bridge calculation upon
	port changes
Date: Wed, 30 Apr 2014 11:38:44 -0700
Message-ID: <CAB=NE6U3o62mbDbL7Uaoe1r44xAXqW+iYM6y9jxP+UvM4kvYHw@mail.gmail.com>
References: <1394680527-28970-1-git-send-email-mcgrof@do-not-panic.com>
	<1394680527-28970-3-git-send-email-mcgrof@do-not-panic.com>
	<CAHA+R7Pf6rM5h1uGiqrru5LkN9C7Nm7V42cucHSOV1s7_+F7Gw@mail.gmail.com>
	<20140315013940.GA28801@wotan.suse.de>
	<CAHA+R7MRVyjAN7w_qPxSxkrjo939bNEc3Ej+O3yH-oWj4gGJxw@mail.gmail.com>
	<20140318212243.GD28471@garbanzo.do-not-panic.com>
	<20140422194313.GQ27882@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kvm@vger.kernel.org, Cong Wang <cwang@twopensource.com>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>, xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140422194313.GQ27882@wotan.suse.de>
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

On Tue, Apr 22, 2014 at 12:43 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
> On Tue, Mar 18, 2014 at 02:22:43PM -0700, Luis R. Rodriguez wrote:
>> On Tue, Mar 18, 2014 at 01:46:49PM -0700, Cong Wang wrote:
>> > On Fri, Mar 14, 2014 at 6:39 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
>> > > On Thu, Mar 13, 2014 at 11:26:25AM -0700, Cong Wang wrote:
>> > >> On Wed, Mar 12, 2014 at 8:15 PM, Luis R. Rodriguez
>> > >> <mcgrof@do-not-panic.com> wrote:
>> > >> >                         spin_unlock_bh(&p->br->lock);
>> > >> > +                       if (changed)
>> > >> > +                               call_netdevice_notifiers(NETDEV_CHANGEADDR,
>> > >> > +                                                        p->br->dev);
>> > >> > +                       netdev_update_features(p->br->dev);
>> > >>
>> > >> I think this is supposed to be in netdev event handler of br->dev
>> > >> instead of here.
>> > >
>> > > Do you mean netdev_update_features() ? I mimic'd what was being done on
>> > > br_del_if() given that root blocking is doing something similar. If
>> > > we need to change something for the above then I suppose it means we need
>> > > to change br_del_if() too. Let me know if you see any reason for something
>> > > else.
>> > >
>> >
>> > Yeah, for me it looks like it's better to call netdev_update_features()
>> > in the event handler of br->dev, rather than where calling
>> > call_netdevice_notifiers(..., br->dev);.
>>
>> I still don't see why, in fact trying to verify this I am wondering now
>> if instead we should actually fix br_features_recompute() to take into
>> consideration BR_ROOT_BLOCK as below. Notice how netdev_update_features()
>> is called above even if the MAC address did not change, just as is done
>> on br_del_if(). There is an NETDEV_FEAT_CHANGE event so would it be more
>> appropriate we just call
>>
>> call_netdevice_notifiers(NETDEV_FEAT_CHANGE, p->br->dev)
>>
>> for both the above then and also br_del_if()? How about the below
>> change?
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index 54d207d..dcd9378 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -315,6 +315,8 @@ netdev_features_t br_features_recompute(struct net_bridge *br,
>>       features &= ~NETIF_F_ONE_FOR_ALL;
>>
>>       list_for_each_entry(p, &br->port_list, list) {
>> +             if (p->flags & BR_ROOT_BLOCK)
>> +                     continue;
>>               features = netdev_increment_features(features,
>>                                                    p->dev->features, mask);
>>       }
>
> Cong, can you provide feedback on this? I tried to grow confidence on the
> hunk above but its not clear but the other points still hold and I'd love
> your feedback on those.

Re-poke.

  Luis
