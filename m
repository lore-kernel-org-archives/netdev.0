From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Thu, 14 May 2015 15:19:33 -0400
Message-ID: <12675437.ssZNCck7zG@sifl>
References: <cover.1429252659.git.rgb@redhat.com> <20150512195759.GA9832@madcap2.tricolour.ca> <2918460.dpKocsKt4o@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-audit@redhat.com,
	eparis@parisplace.org, arozansk@redhat.com, serge@hallyn.com,
	zohar@linux.vnet.ibm.com, viro@zeniv.linux.org.uk,
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org
To: Steve Grubb <sgrubb@redhat.com>,
	Richard Guy Briggs <rgb@redhat.com>, ebiederm@xmission.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <2918460.dpKocsKt4o@x2>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 14, 2015 10:57:14 AM Steve Grubb wrote:
> On Tuesday, May 12, 2015 03:57:59 PM Richard Guy Briggs wrote:
> > On 15/05/05, Steve Grubb wrote:
> > > I think there needs to be some more discussion around this. It seems
> > > like this is not exactly recording things that are useful for audit.
> > 
> > It seems to me that either audit has to assemble that information, or
> > the kernel has to do so.  The kernel doesn't know about containers
> > (yet?).
> 
> Auditing is something that has a lot of requirements imposed on it by
> security standards. There was no requirement to have an auid until audit
> came along and said that uid is not good enough to know who is issuing
> commands because of su or sudo. There was no requirement for sessionid
> until we had to track each action back to a login so we could see if the
> login came from the expected place.
> 
> What I am saying is we have the same situation. Audit needs to track a
> container and we need an ID. The information that is being logged is not
> useful for auditing. Maybe someone wants that info in syslog, but I doubt
> it. The audit trail's purpose is to allow a security officer to reconstruct
> the events to determine what happened during some security incident.

As Eric, and others, have stated, the container concept is a userspace idea, 
not a kernel idea; the kernel only knows, and cares about, namespaces.  This 
is unlikely to change.

However, as Steve points out, there is precedence for the kernel to record 
userspace tokens for the sake of audit.  Personally I'm not a big fan of this 
in general, but I do recognize that it does satisfy a legitimate need.  Think 
of things like auid and the sessionid as necessary evils; audit is already 
chock full of evilness I doubt one more will doom us all to hell.

Moving forward, I'd like to see the following:

* Record the creation/removal/mgmt of the individual namespaces as Richard's 
patchset currently does.  However, I'd suggest using an explicit namespace 
value for the init namespace instead of the "unset" value in the V6 patchset 
(my apologies if you've already changed this Richard, I haven't looked at V7 
yet).

* Create a container ID token (unsigned 32-bit integer?), similar to 
auid/sessionid, that is set by userspace and carried by the kernel to be used 
in audit records.  I'd like to see some discussion on how we manage this, e.g. 
how do handle container ID inheritance, how do we handle nested containers 
(setting the containerid when it is already set), do we care if multiple 
different containers share the same namespace config, etc.?

* When userspace sets the container ID, emit a new audit record with the 
associated namespace tokens and the container ID.

* Look at our existing audit records to determine which records should have 
namespace and container ID tokens added.  We may only want to add the 
additional fields in the case where the namespace/container ID tokens are not 
the init namespace.

Can we all live with this?  If not, please suggest some alternate ideas; 
simply shouting "IT'S ALL CRAP!" isn't helpful for anyone ... it may be true, 
but it doesn't help us solve the problem ;)

-- 
paul moore
security @ redhat

