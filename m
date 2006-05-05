From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] Proposed structure for Regulatory/Geographical Wireless
	database
Date: Fri, 05 May 2006 17:10:35 -0400
Message-ID: <1146863436.32242.23.camel@localhost.localdomain>
References: <445BB22B.30505@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Faidon Liambotis <faidon@cube.gr>,
	Rick Jones <rick.jones2@hp.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Harald Welte <laforge@gnumonks.org>,
	Jouni Malinen <jkm@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:22506 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751782AbWEEVMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 17:12:31 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <445BB22B.30505@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-05 at 15:14 -0500, Larry Finger wrote:
> Thanks to all that responded to my earlier RFC. A number of changes in my thinking are based on 
> those comments, which came from Christoph Hellwig, Rick Jones, Ulrich Kunitz, Faidon Liambotis, 
> Jouni Malinen,  and Harald Welte.  The important points of my proposal are as follows:
> 
> * The database will be maintained as a text file to be processed by a userland daemon that will 
> transform this database into the data structure needed by the ieee80211 code. In addition to the 
> regulatory data, this file will also contain the information needed for the daemon to set the size 
> of its data arrays dynamically.

Can you explain a bit more about the dynamic array aspect here?  What's
that about?  Shouldn't the geo-daemon be able to figure this stuff out
automatically and tell the ieee80211 stack how many countries and groups
there are?  It has to parse the file anyway, so it should surely know
how many groups and countries there are after parsing it.  (or do I just
not understand the issues...?)

> * A new routine (ieee80211_init_geo ?) will be written to be called by the driver to load the geo 
> structure into the kernel. Information passed to the daemon will be the country code in ASCII and 
> whether the interface is to be used indoors or outdoors.
> 
> * Checksum routines will be used to validate the data base. Such a simple scheme will not inhibit 
> anyone with moderate skills from hacking the channel/power settings, but such hacking will require 
> some effort.

What I'm concerned about is error reporting.  And as a distro packager,
I don't want any user to have to touch the geo file.  That's fine if
they do, but nobody should _have_ to.

For error reporting, if the geo file does not exist, or contains invalid
information, or if the checksum doesn't match for some reason, what's
the failure case?  It's not sufficient to just log that to dmesg and
fail the attempt, because then a program like wpa_supplicant or
NetworkManager will have no clue what the problem is if the driver just
returns ENOENT or EFILESUCKS or whatever.  This is the same problem we
currently have with missing firmware.  The failure case is not clearly
recognizable by the client.

If the geo data fails to be read, or fails to be validated by the
driver, user apps that are trying to make connection attempts need to
know exactly why the attempt failed, so they can inform users of the
failure in a smart way.  That information needs to come through the
driver, because user apps that make network connection attempts
shouldn't have to talk to the regulatory daemon _at all_.

Conceptually, the regulatory/geo daemon is part of the kernel and the
driver, and just happens to live in userspace because policy
+kernel==ohmygodbad.  But that means that it's the kernel's
responsibility to marshal the error information back to clients of the
wireless driver, not the clients problem to ask the regulatory/geo
daemon, if it's actually running, what the heck the problem is and why
the driver returned the error code it did.

U  NetworkManager     geo-daemon
------------|-----------|-----------
K           |           |
           driver/iee80211

Think of it as a V, not a triangle.  That's where we need to be WRT
error reporting.

Dan


