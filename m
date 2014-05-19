From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0
 (bridge : Sanitize skb before it enters the IP stack)
Date: Mon, 19 May 2014 22:49:32 +0200
Message-ID: <537A6E5C.6090602@pandora.be>
References: <537621AC.1060409@davidnewall.com>
	<5379FFFD.1050705@davidnewall.com>
	<20140519140119.GA24523@breakpoint.cc>
	<537A12EA.4060604@davidnewall.com>
	<20140519170915.GB24523@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, bridge@lists.linux-foundation.org,
	netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>,
 David Newall <davidn@davidnewall.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140519170915.GB24523@breakpoint.cc>
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

Florian Westphal schreef op 19/05/2014 19:09:
> David Newall <davidn@davidnewall.com> wrote:
>
> [ remove lkml and cc nf-devel ]
>
>> I tried to persevere with the commit: I recalculated checksum, which
>> left routes and times improperly updated in options.  Then I tried
>> calling ip_forward_options, which looks like it would correctly
>> update RR and TS (not to mention checksum)m but that bombed because
>> skb_rtable returned NULL.
>
> Yes.  bridge<->netfilter wiring is pure duct tape.
> The glue code will set up a fake rtable for the skb after the
> prerouting hook. [ see br_nf_pre_routing_finish() ].
>
>> I see three ways to progress:
>>
>> 1. Possibly call ip_forward_option, but that requires somebody who
>> understands this code to help;
>> 2. Just recalculate the checksum, leaving crap in the options; or
>> 3. Revert the commit.
>
> I think none of these are an option.
>
> I fail to understand why a bridge should honor/modifiy IP options.
>
> For the 'local delivery' case the ip stack will take care of
> option parsing, for forwarding it should be sufficient to do
> sanity tests (for netfilters sake).
>
>>From a quick glance, it should be sufficient to edit
> br_parse_ip_options() and remove everything after
>
> memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
>
> A 2nd step would be to move a copy of ip_options_compile()
> into br_netfilter.c and trim it down to only validate the
> ipv4 header without modifying it.

Perhaps it's possible to call ip_options_compile with a skb == NULL, 
like ip_options.c::ip_options_get_finish does. That way we don't need to 
duplicate code.
An alternative would be to make sure that the data pointed to by IPCB 
and BR_INPUT_SKB_CB don't overlap. If this were the case, we could 
indeed just revert the commit that was referred to.


cheers,
Bart
