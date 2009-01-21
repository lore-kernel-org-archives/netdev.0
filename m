From: "Rob Meijer" <capibara@xs4all.nl>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal  
     firewalls"
Date: Wed, 21 Jan 2009 10:32:54 +0100 (CET)
Message-ID: <39767.77.61.51.106.1232530374.squirrel@webmail.xs4all.nl>
Reply-To: rmeijer@xs4all.nl
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: rmeijer@xs4all.nl, "Casey Schaufler" <casey@schaufler-ca.com>,
	"Samir Bellabes" <sam@synack.fr>, imipak@yahoo.com,
	"linux-security-module" <linux-security-module@vger.kernel.org>,
	"Stephan Peijnik" <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Peter Dolding" <oiaohm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr10.xs4all.nl ([194.109.24.30]:1825 "EHLO
	smtp-vbr10.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392AbZAUJdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 04:33:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, January 21, 2009 09:15, Peter Dolding wrote:

> Netfilter can already reject or approve out going packets from
> applications on the base of user id process id and so on.  This is
> before packets enter the Netfilter processing stack.   Cost of looking
> up if applicaiton is approved or not appoved is out weight be the cost
> of rejected packets going trough netfilter.
>
> Sorry netfilter is already sorting out how sockets can be used.   What
> you are basically talking about is two layors doing exactly the same
> thing.   Half of what tuxguardian does can be done in a iptables
> module.  Ie filtering out going traffic based on application.
>
> Please explain why expanding netfilter is not a option.   Expanding
> netfilter avoids conflicts with LSM's.
>

Agreed patches to Netfilter might get you a long way. Along the lines of
--owner-uid you may extend it with something like --owner-exe and possibly
--owner-callchainid. That could take care of:

* connection-full-protocol like TCP
* outgoing connection-less-protocol packets like UDP or ICMP

The one thing that would remain would be incoming connection-less-protocol
packets. If Netfilter could be patched in such a way that incoming packets
could be filtered based on receiving process meta, that would be a great
way to go. If not, maybe LSM would need to just mediate 'bind'.

A second issue comes with user level administration. If Netfilter would be
patched to allow a user to administrate her 'private' table, that could
get called from the system wide Netfilter rules, some MAC framework would
still be needed to make sure the user has a way to change the rules in her
private table, but her browser, pdf reader, mail client etc have not.

That is, you could define some system wide ruleset like:

System wide:
  * deny any packet from executables under '/home/*'
  * deny any packet from user 'localuser'
  * for any packet from an executable under /usr/bin/networkingtools/ jump
    to the users USERPRIVATE table.
  * deny all other trafic.

User alice USERPRIVATE:
  * allow all packets from /usr/bin/webbrowser to anything on tcp port 80.

User bob USERPRIVATE:
  * allow all packets from /usr/bin/webbrowser to the socks port of the
    socks server.

Would a solution like that be feasible?

You would want alice or bob to be able to change their USERPRIVATE table,
but you wouldn't want /usr/bin/webbrowser or any other program to do so
independently. At least for that you would need close cooperation with
for example SeLinux or AppArmor.

Further it seems that 'bind' for connection less sockets will still be
important a candidate for mediation by LSM IMHO.

Rob.

