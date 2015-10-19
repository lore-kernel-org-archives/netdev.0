From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Mon, 19 Oct 2015 16:13:42 -0700
Message-ID: <CANr6G5wLhz6UcBp0_a_cCnofJFyY43CU290Uu8+RKiDmUZccqA@mail.gmail.com>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-3-git-send-email-joestringer@nicira.com>
 <20151017075233.GC13981@pox.localdomain> <CANr6G5xmO6D0Yu0VXeaJLbO1aK2tQ5_vHUNRkawK1zNFMJz=aw@mail.gmail.com>
 <20151019090332.GA7104@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36401 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbbJSXOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 19:14:03 -0400
Received: by ykdz2 with SMTP id z2so392389ykd.3
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 16:14:02 -0700 (PDT)
In-Reply-To: <20151019090332.GA7104@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 October 2015 at 02:03, Thomas Graf <tgraf@suug.ch> wrote:
> On 10/19/15 at 12:07am, Joe Stringer wrote:
>> > I'm probably missing something obvious. Why is the reply direction
>> > not considered NEW? Wouldn't this consider an ICMPv6 as related+new
>> > depending on simply the direction?
>>
>> My thoughts were along the lines "If something is a reply, that
>> implies that state is held, and therefore it cannot be NEW (where NEW
>> means no state is available)". However, if you consider that the
>> 'related' connection is an independent connection with its own state,
>> but the 'reply' bit refers to the original connection, my original
>> premise breaks. Furthermore, looking at how it's used in netfilter
>> core and the ICMP proto handler, it looks like both of these cases
>> should be considered NEW. I can respin.
>>
>> Do you have a specific case in mind here? It would be useful for
>> extending the OVS testsuite.
>
> It's tricky. A typical use case would be an active FTP connection
> where the data connection is established in the reply direction
> and marked related if I'm not mistaken.
>
> OTOH, an ICMP sent in response should not be considered NEW. It
> really depends on our definition of NEW towards the user.

ICMP and FTP are handled a bit differently: ICMP protocol handling is
based on the original connection; however for expected connections
like FTP data, there is a separate conntrack entry. I agree that for
ICMP errors, they should not be NEW; but for active FTP connections,
I'd expect the data connection to be NEW (if it wasn't already
seen&established). Along these lines, my earlier assertion that the
'reply' flag is based on the original connection is only applicable
for ICMP responses, but not for FTP data connections.

I think that the proper solution instead of this patch is to set NEW
if !nf_ct_is_confirmed(ct). This is more accurately the meaning for
'NEW' that we are actually trying to expose. As long as this is done
before confirming the connection during a "commit", this will make the
behaviour consistent with the lack of commit flag. I'm sending a
patch. Thanks for the feedback!
