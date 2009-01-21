From: Peter Dolding <oiaohm@gmail.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
	firewalls"
Date: Thu, 22 Jan 2009 09:28:35 +1000
Message-ID: <e7d8f83e0901211528ue344783qb66e481902274961@mail.gmail.com>
References: <39767.77.61.51.106.1232530374.squirrel@webmail.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Samir Bellabes <sam@synack.fr>, imipak@yahoo.com,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: rmeijer@xs4all.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:11080 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbZAUX2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 18:28:37 -0500
In-Reply-To: <39767.77.61.51.106.1232530374.squirrel@webmail.xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 7:32 PM, Rob Meijer <capibara@xs4all.nl> wrote:
> On Wed, January 21, 2009 09:15, Peter Dolding wrote:
>
>> Netfilter can already reject or approve out going packets from
>> applications on the base of user id process id and so on.  This is
>> before packets enter the Netfilter processing stack.   Cost of looking
>> up if applicaiton is approved or not appoved is out weight be the cost
>> of rejected packets going trough netfilter.
>>
>> Sorry netfilter is already sorting out how sockets can be used.   What
>> you are basically talking about is two layors doing exactly the same
>> thing.   Half of what tuxguardian does can be done in a iptables
>> module.  Ie filtering out going traffic based on application.
>>
>> Please explain why expanding netfilter is not a option.   Expanding
>> netfilter avoids conflicts with LSM's.
>>
>
> Agreed patches to Netfilter might get you a long way. Along the lines of
> --owner-uid you may extend it with something like --owner-exe and possibly
> --owner-callchainid. That could take care of:
>
> * connection-full-protocol like TCP
> * outgoing connection-less-protocol packets like UDP or ICMP
>
> The one thing that would remain would be incoming connection-less-protocol
> packets. If Netfilter could be patched in such a way that incoming packets
> could be filtered based on receiving process meta, that would be a great
> way to go. If not, maybe LSM would need to just mediate 'bind'.
>
> A second issue comes with user level administration. If Netfilter would be
> patched to allow a user to administrate her 'private' table, that could
> get called from the system wide Netfilter rules, some MAC framework would
> still be needed to make sure the user has a way to change the rules in her
> private table, but her browser, pdf reader, mail client etc have not.
>
> That is, you could define some system wide ruleset like:
>
> System wide:
>  * deny any packet from executables under '/home/*'
>  * deny any packet from user 'localuser'
>  * for any packet from an executable under /usr/bin/networkingtools/ jump
>    to the users USERPRIVATE table.
>  * deny all other trafic.
>
> User alice USERPRIVATE:
>  * allow all packets from /usr/bin/webbrowser to anything on tcp port 80.
>
> User bob USERPRIVATE:
>  * allow all packets from /usr/bin/webbrowser to the socks port of the
>    socks server.
>
> Would a solution like that be feasible?
>
> You would want alice or bob to be able to change their USERPRIVATE table,
> but you wouldn't want /usr/bin/webbrowser or any other program to do so
> independently. At least for that you would need close cooperation with
> for example SeLinux or AppArmor.
>
> Further it seems that 'bind' for connection less sockets will still be
> important a candidate for mediation by LSM IMHO.
>
More than feasible.   Look at cgroup's network stack work.   Stick
each user in there own Cgroup and they can even have there own IP
number and table if they like.   Of course cannot effect the table
outside the Cgroup.   Its the one of the major reasons why I said
fixing up netfilter to provide what is required makes doing multi user
simple.

Rules there would only be a extension to what cgroup networking and
netfilter.  Yes no LSM involvement required.

There are many ways though the Linux kernel.  This is part of the
reason why I am asking why they are wanting LSM so much.  LSM was
decided to be only one thing.   Not something to make more of if it
can be avoided.   First rule should be seeing if API and Internal
structs of Linux need fixing.  This case yes there are quite a few
weaknesses in netfilter that could do with fixing.   If after fixing
netfilter up it still turns out you need LSM support then you do have
a valid reason.

Bind not blocking is a defect in netfilter.   Bind call informs
netfilter that the traffic to that location is wanted.   One problem
netfilter cannot answer blocked.   Bind is not a LSM issue really.
Its a API issue between bind and netfilter.   Currently netfilter just
cuts the traffic off on the other side.  Ie you have binded to a port
and will receive nothing because no traffic will get to you.  Its also
not per application its global.    Yes netfilter rules store the
information need for blocking bind just no way of informing
application that it is.

Peter Dolding
