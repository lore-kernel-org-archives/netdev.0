From: Jonas Danielsson <jonas.danielsson@axis.com>
Subject: Regression introduced by commit dbe9a4173ea53
Date: Fri, 23 Jan 2015 15:16:23 +0100
Message-ID: <20150123141623.GK30451@lnxjonasdn.se.axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<ebiederm@xmission.com>, <luto@amacapital.net>, <rgb@redhat.com>,
	<johannes.berg@intel.com>, <viro@zeniv.linux.org.uk>,
	<akpm@linux-foundation.org>, <fabf@skynet.be>,
	<brian.cambell@editshare.com>, <mpatocka@redhat.com>,
	<tgraf@suug.ch>, <eric.dumazet@gmail.com>, <desrt@desrt.ca>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have seen a regression, that I think is caused by:

commit dbe9a4173ea53b72b2c35d19f676a85b69f1c9fe
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Sep 6 18:20:01 2012 +0000

    scm: Don't use struct ucred in NETLINK_CB and struct scm_cookie.


With this commit the value send as uid when credentials are missing
changes from -1 to overflowuid (default -2, the 'nobody' user).

I was using dbus-send to perform a method call on a gdbus server.
And sometimes I fall victim to the race condition caused by:

commit 16e5726 ("af_unix: dont send SCM_CREDENTIALS by default")

And then there will be no credentials on the socket. The glib library checks
the uid, and if it is -1, it will fall back to using SO_PEERCRED and things
will work for me. But since the commit in $subject changes the uid I get
failure with NoReply from dbus-send.

It seems that before the commit in $subject that the function from_kuid_munged
was only called if there were credentials present. Otherwise we would set uid
to -1. Now uid gets set to -1 if there is no credentials but from_kuid_munged
is always called. And from the documentation of from_kuid_munged it states
that it 'never fails and always returns a valid uid'. And in the case of
uid being -1, it returns overflowuid.

So this seems like it broke glib. Caused by 1) the introduced race condition
that makes it not totally safe to set SO_PEERCRED on the accepted socket and
2) that the value of uid when credentials are missing changed from -1 to
overflowuid.

Thanks for your time
Jonas
