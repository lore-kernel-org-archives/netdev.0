From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Network Events Connector
Date: Mon, 2 Oct 2006 17:13:45 +0400
Message-ID: <20061002131345.GA18129@2ka.mipt.ru>
References: <m23ba7gscl.fsf@cerbere.dyndns.info> <20061002090222.GA32591@2ka.mipt.ru> <m2r6xqg9ik.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:28051 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932311AbWJBNNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 09:13:48 -0400
To: Samir Bellabes <sbellabes@mandriva.com>
Content-Disposition: inline
In-Reply-To: <m2r6xqg9ik.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 02:57:55PM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
> 
> > On Mon, Oct 02, 2006 at 08:11:06AM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
> >> 
> >> This patch adds a connector which reports networking's events to
> >> userspace. It's sending events when a sock has its sk_state changed to :
> >>   - LISTEN or CLOSE for DCCP and TCP
> >>   - BIND or CLOSE for UDP.
> >> 
> >> With this notification, a userspace tool can ask the user if he want to
> >> let the local firewall open for the corresponding sport or not, and if
> >> so open the firewall for the application which get the corresponding sport.
> >> 
> >> For people behind a firewall (non-running in the user box) we can have a
> >> authentification between the user box, which have set the port to state
> >> TCP_LISTEN for example, and the firewall, in a such way that the
> >> firewall's router will forward incoming packet for this port to the user
> >> box.
> >> 
> >> It will avoid adding specific rules to the user's firewall-script, and
> >> let the firewall be more interactive for users.
> >> 
> >> Signed-off-by: Samir Bellabes <sbellabes@mandriva.com>
> >
> > Interesting... Mybe it even prints the name of the application which is
> > trying to change port state?
> 
> Yes, of course, the name of the application is a part of the 'trusted
> system'. But i think we can look for the application which gets the
> inode corresponding to the sock in userspace, using the /proc/<pid>
> files. 
> Whithout this, we have to lookup all the process in kernel, in order to
> find the one which old the sock. It's time consumming, even if the kind
> of event involved (listening/close port) doesn't occur so often.
> But if you think the kernel can do that, it's not a problem, i have code
> to do that.

It is much better to do it in userspace - look into /proc/$pid/.

I recall I saw such feature in Windows :)

You can also extend your module to be more generic and send all (or just
requested in config) state changes for all protocols (or those checked
in config).
 
> In fact the '$PATH/apps' is the complete info we need. With it,
> we can ask the user, and we can check with the 'distro' tools (urpmi,
> apt-get, smart) if the '$PATH/apps' really belongs to the distro and
> should be trust.
> 
> I'm working also in a option on this, in order to avoid some 'false
> positive', because some ports don't need to be 'open' in the firewall,
> using conntrack.
> As a example, you can take ftp's client, which will own a listening port
> when it will received data from server, but the ip/nf_conntrack_ftp will
> do the jobs for us, in order to let the data coming in.
> This current patch will send the information that the ftp's client is
> listening on a port (and a userspace tool will ask the user about what
> to do with this) but the ip_conntrack as already did the job.
>
> > I have couple of comments about structures you use, otherwise it looks
> > good, although I do not know if it is ok or not ok to include it into
> > mainline tree.
> > From one point of view it is small and interesting piece of code, from other
> > point it is not clear if such functionality is needed...
> 
> ok.
> 
> > Btw, you could also create netlink/connector based firewall rules
> > update, I think people with hundreds of rules in one table will bless
> > you after that.
> 
> This is the real goal, using ipset - http://ipset.netfilter.org/
> With this we can easily create a uniq rule for iptables, and then
> add/remove port from the 'set' involve.

It is not the same as create and update existing rules.
I think hipac project uses feature of fast rules update.
It is quite major break for existing iptables, but it should be
eventually done...

-- 
	Evgeniy Polyakov
