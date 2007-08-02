From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Fri, 3 Aug 2007 02:51:33 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708022153200.27120@kivilampi-30.cs.helsinki.fi>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu>
 <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
 <20070729085427.GA22784@1wt.eu> <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi>
 <20070729160721.GA31276@1wt.eu> <46AEC286.2030302@netbauds.net>
 <Pine.LNX.4.64.0708021056560.8788@kivilampi-30.cs.helsinki.fi>
 <46B20D48.7060704@netbauds.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1536693790-1186082123=:27120"
Cc: Netdev <netdev@vger.kernel.org>
To: Darryl Miles <darryl-mailinglists@netbauds.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:32891 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674AbXHBXve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 19:51:34 -0400
In-Reply-To: <46B20D48.7060704@netbauds.net>
Content-ID: <Pine.LNX.4.64.0708030148320.27233@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1536693790-1186082123=:27120
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0708030116361.27233@kivilampi-30.cs.helsinki.fi>

...I dropped lkml, it's useless to bother them with this network related 
stuff...

On Thu, 2 Aug 2007, Darryl Miles wrote:
> Ilpo Järvinen wrote:
> > On Tue, 31 Jul 2007, Darryl L. Miles wrote:

[...RFC bashing, snip...] 

>  * The older linux kernel for not being 100% SACK RFC compliant in its
> implementation ?  Not a lot we can do about this now, but if we're able
> to identify there maybe backward compatibility issues with the same
> implementation thats a useful point to take forward.
>
>  * The newer linux kernel for enabling D-SACK by default when RFC2883
> doesn't even claim a cast iron case for D-SACK to be compatible with any
> 100% RFC compliant SACK implementation.

Are you aware that D-SACK processing and generation has been part of the 
linux kernel TCP far before 2.6 series even begun... ...and it goes far 
beoynd that, 2.4.0 had it too (2.2.0 didn't seem to have it, never before 
have I read that one IIRC :-) ).

> Does Ilpo have a particular vested interest in D-SACK that should be 
> disclosed?

Sure :-). ...my interest was to show you that it's not a bug :-).

> So it is necessary to turn off a TCP option (that is enabled by default)
> to be sure to have reliable TCP connections (that don't lock up) in the
> bugfree Linux networking stack ?  This is absurd.

...You'll have to turn a lot off to be compatible with everything around 
Internet, and still you would probably fail. Some people have to, e.g., to 
turn of window scaling to work-around buggy intermediate nodes (nat boxes 
or some firewalls), there's even a sysctl to workaround signed 16-bit 
window arithmetic bugs that's mostly legacy but I bet you can find host 
broken in that area too. Etc. Yet we don't off those by default.

> If such an option causes such a problem; then that option should not be
> enabled by default. 

...Linux TCP has enabled by default option which are _known_ (at least 
nowadays) to cause bad problems and many of them are _still_ enabled... 
Browse archives if you don't believe me... And I'm relatively sure it will 
do so also in future though I'm not the maintainer nor "anybody" to make 
such decisions...

> rather than wallpaper over the cracks with the voodoo of turning things 
> that are enabled by default off.

...I said that because it felt like you kept repeating that the generated 
DSACK block is a bug even though, like you now know, it's a feature, not a 
bug. :-)

> > 2) The ACK got discarded by the SERVER
> 
> I'd thought about that one, its a possibility.  The server in question
> does have period of high UDP load on a fair number of UDP sockets at
> once (a few 1000).  Both systems have 2Gb of RAM.  The server has maybe
> just 250Mb of RSS of all apps combined.

...There are three independent signs in the log to indicate discard out
of these 3 reasons. Whereas your theory _fails_ to explain some behavior 
in the log you presented, e.g., not updated timestamp which happen even 
_before_ the DSACK stuff?!?... I'll formulate this question: why didn't 
snd_una advance nor timestamp update though a cumulative ACK arrived?
You can check for yourself (in server log):

03:58:56.384503
03:58:56.462583
03:58:56.465707
03:58:56.678546

...I'm hoping SNMPs provide explanation to it.

> The client sent a SACK.  But from understanding more about D-SACK, this
> is a valid D-SACK response, but it appears to confuse the older Linux
> kernel at the server end.

...Are you saying that it's confused by _DSACK_ just because it's only 
"strange" thing you seem to find from the log? I see other things in your 
log which are exceptional and point to elsewhere... Please don't neglect 
them... ...Problems occur already before that DSACK is received by the 
server end.

> Agreed on this.  However discarding data is allowed (providing it is
> intentional discarding not a bug where the TCP stack is discarding segments it
> shouldn't), TCP should recover providing sufficient packets get through.

But if one end decides to discard everything after time t, TCP _will
not_ recover because "sufficient packets" won't "get through"... And 
that's what your log is telling me. Yes discarding is allowed but that 
wasn't the point, we're more interested here on why it got discarded
rather than allowance of discarding.

> Forgive me if I am mistaken, but while the server reports a checksum
> error, the client did not.  I took this to be a misreporting by tcpdump
> at the server, probably due to the "e1000" network card checksum
> offloading

...That's probably the reason, I agree, these show up. Thought that also 
myself, besides, it wouldn't cause that kind of breakage anyway.

> So the SNMP data would show up intentional discards (due to memory/resource
> issues).  So I'll get some of those too.
> 
> The SNMP stats aren't so useful right now as
> the box has been rebooted since then but I shall attempt to capture
> /proc/net/* data, cause the problem, then capture /proc/net/* data again
> if those numbers can help.

Good, thanks. 

-- 
 i.
---696243703-1536693790-1186082123=:27120--
