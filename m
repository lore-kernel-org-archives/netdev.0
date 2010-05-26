From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] IFLA_PORT_* iproute2 cmd line
Date: Wed, 26 May 2010 14:38:06 +0200
Message-ID: <201005261438.07004.arnd@arndb.de>
References: <C821E15E.35236%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Wright <chrisw@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Stefan Berger <stefanb@us.ibm.com>,
	Dirk Herrendoerfer <d.herrendoerfer@de.ibm.com>,
	Vivek Kashyap <vivk@us.ibm.com>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:55506 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870Ab0EZMi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 08:38:27 -0400
In-Reply-To: <C821E15E.35236%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 May 2010, Scott Feldman wrote:
> I need to provide an iproute2 patch for IFLA_PORT_* and I wanted to hash out
> the cmd line before I submit it.  Here's what I think would work based on
> previous input from Arnd:
> 
> Usage:  ip port associate DEVICE [ vf NUM ] {PROFILE|VSI}
>         ip port pre-associate DEVICE [ vf NUM ] VSI
>         ip port pre-associate-rr DEVICE [ vf NUM ] VSI
>         ip port dis-associate DEVICE [ vf NUM ]
>         ip port show [ DEVICE [ vf NUM ] ]
> 
>         PROFILE := port-profile PORT-PROFILE
>                    [ instance-uuid INSTANCE-UUID ]
>                    [ host-uuid HOST-UUID ]
> 
>         VSI := vsi managerid MGR typeid VTID typeidversion VER
>                [ instance-uuid INSTANCE-UUID ]
> 
> Comments?

The syntax of the PROFILE and VSI arguments seems ok, but I'm
not sure where exactly to put them.

When talking to the kernel, I think this should be part of 
link command, because that is the underlying protocol:

ip link set DEVICE [vf NUM] {associate {PROFILE|VSI}    |
			     pre-associate-rr VSI       |
			     pre-associate VSI          |
			     disassociate }
ip link show [ DEVICE [ vf NUM ] ] 

This will also let you combine the association with additional
"vf mac" and "vf vlan" commands as needed.

The more interesting question is how to do this when we
talk to lldpad. One idea was to use the same protocol
but to direct the message to a specific pid (that of lldpad).
That would require adding an option like '-p PID' to ip
that lets us change who we talk to.

Alternatively, we could also create a top-level command like
the one you described, but just use it for the case when
we're talking to lldpad, finding out the PID from the
/var/run/lldpdad.pid internally. Right now, I'm leaning
towards the more flexible option of being able to direct
the command anywhere.

	Arnd
