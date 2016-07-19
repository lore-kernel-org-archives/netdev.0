From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 19 Jul 2016 15:21:36 +0200
Message-ID: <578E2960.7080709@iogearbox.net>
References: <1468744884-8246-1-git-send-email-jhs@emojatatu.com> <20160718041933.GB36253@ast-mbp.thefacebook.com> <578C7C5C.2070804@mojatatu.com> <578CA4EB.7060703@iogearbox.net> <578CAA96.2090501@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48755 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987AbcGSNVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 09:21:40 -0400
In-Reply-To: <578CAA96.2090501@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2016 12:08 PM, Jamal Hadi Salim wrote:
> On 16-07-18 05:44 AM, Daniel Borkmann wrote:
>> On 07/18/2016 08:51 AM, Jamal Hadi Salim wrote:
>>> On 16-07-18 12:19 AM, Alexei Starovoitov wrote:
>
>> Looking at that just out of curiosity on how complex it could look
>> for src/dst mac, is it actually functional in iproute2 upstream tree?
>
> No it is a bunch of bash script wrapping we did on top of pedit (which
> should be no different than adding it to m_pedit as an extension).
> We started there then decided that this feature is mostly used with
> mirred all the time - so modified  mirred.
>
>> All I see is that pedit can look up 3rd party modules via get_pedit_kind(),
>> so it will pick p_%s.so, if built as such, and there's code for p_ip,
>> p_tcp, p_udp, p_icmp. But then, for example, all I see in p_udp.c is
>> since initial iproute2 import in 2005, apart from some cleanups by
>> Stephen:
>
> Yes, IP and tcp should be fine. Others were place holders.

Well, kind of, also TCP is a place holder here:

static int
parse_tcp(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
{
	int res = -1;
	return res;
}
struct m_pedit_util p_pedit_tcp = {
	NULL,
	"tcp",
	parse_tcp,
};

Ohh well, and the IP module implements couple of ICMP stuff and source/dest port
editing ... so only some parts of the IPv4 bits are usable it seems.

>> Same for tcp, icmp, ipv6 bits code ... :/ Is it still planned to eventually
>> complete these?
>
> someone else could run with it; at the moment i think this was ok at
> small scale but it hasnt worked well in a larger scale. When you write

I believe no-one really bothered to seriously use these p_* modules in
large (maybe even small) scale given their state. Maybe it would have been
different if this functionality was more complete from the beginning (analog
to u32 cls). True that script wrappers might do the same, but would have more
work once you'd add some 'pretty printer' to it.

> other apps (other than tc) to use these APIs parsing all the 32 bit
> chunks is more cumbersome then getting a struct which gives me precise
> info.

True, the 32 bit chunks are more generic and as such you need to put more
effort in user space to handle them, but at the same time gain more flexibility
w/o having to have a module for each and every proto. But apart from this,
neither pedit nor tcf_skbmod_run() here handle checksum complete, so you'll
potentially get false positives wrt csum corruption and drops as a result
when using either of the two.

[...]
> If i could tag the structure with something the kernel then returns to
> me when i dump, I could add nice pretty printers (same arguement applies
> to u32).
> But that doesnt solve the programmability issue as being a good cause.
>
> cheers,
> jamal
>
>
>
