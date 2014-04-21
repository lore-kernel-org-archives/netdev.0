From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Mon, 21 Apr 2014 08:47:51 -0700
Message-ID: <CALCETrW5RvbW-Hz_Y7oULP6sEfdhGBh51+mTj4RwobHV-ji+Kg@mail.gmail.com>
References: <CALCETrXj6kD3E+vsaWmkrSbaQYTu=c-Hsw640jh4O+FbojYk2g@mail.gmail.com>
 <20140417171256.GB25334@redhat.com> <CALCETrVq4HRpfWOAbZAQbyjuraQd=OxnW=WjSoe5JgBzRStiKg@mail.gmail.com>
 <1397756025.2628.64.camel@willson.li.ssimo.org> <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
 <1397759013.2628.86.camel@willson.li.ssimo.org> <20140417185023.GA32527@redhat.com>
 <1397761817.2628.113.camel@willson.li.ssimo.org> <20140417191646.GA2461@redhat.com>
 <CALCETrW3F1+3qF3thrAmuoWVbRveBJ2=owpigh4mv6iAafoQCw@mail.gmail.com> <20140421150307.GA4367@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simo Sorce <ssorce@redhat.com>, Daniel J Walsh <dwalsh@redhat.com>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140421150307.GA4367@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 21, 2014 at 8:03 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> So what happened to logger use case where logger accepts stream
> connections and logs the cgroup of client too.
>
> W.r.t systemd, looks like journald is accepting connections at
> /run/systemd/journal/stdout. (stdout_stream_new() and
> server_open_stdout_socket()).

See stdout_stream_line.  As far as I can tell, journald already
implements this in mostly sensible manner, with no help from the
kernel required.

On my system, journalctl -f -o verbose says:

Mon 2014-04-21 08:34:52.732065 PDT
[s=4970edca25b4456d80b00e6e4cefd94b;i=2010;b=2d2454632c0f4f998a8d0158156ab743;m=66f5d274a;t=4f78f3d9a11a1;x=9902671f5a7e7bcc]
    _UID=0
    _BOOT_ID=2d2454632c0f4f998a8d0158156ab743
[...]
    _GID=500
    _AUDIT_SESSION=1
    _AUDIT_LOGINUID=500
    _SYSTEMD_CGROUP=/user.slice/user-500.slice/session-1.scope
    _SYSTEMD_SESSION=1
    _SYSTEMD_OWNER_UID=500
    _SYSTEMD_UNIT=session-1.scope
    _SYSTEMD_SLICE=user-500.slice
    SYSLOG_IDENTIFIER=sudo
    _COMM=sudo
    _EXE=/usr/bin/sudo
    _SELINUX_CONTEXT=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
    MESSAGE=luto : TTY=pts/1 ; PWD=/home/luto/apps/systemd ; USER=root
; COMMAND=/usr/bin/journalctl -f -a
    _PID=32393
    _CMDLINE=sudo journalctl -f -a
    _SOURCE_REALTIME_TIMESTAMP=1398094492732065

Unfortunately, the code in journald seems to be rather buggy and
prefers the unit that it derives from the (racy!) cg_path_get_unit
hack over the unit that is *already knows* (search the journald
sources for STDOUT_STREAM_UNIT_ID), but the right fix is the FIX THE
FSCKING JOURNALD BUG, not to change the kernel.

To summarize from my reading of how this crap words:

When a unit is created, systemd opens a stream socket pointing at
/run/systemd/journal/stdout.  It tells journald the unit, along with
lots of other useful information.  journald records this association
between the socket and the unit.  Systemd could tell journald the
cgroup here, too, if it wanted it.

Systemd then starts the unit, passing it the socket as stdout, if
configured to do so.

That unit logs something.  Journald then uses the crappy, racy ucred
mechanism to resolve the cgroup, login id, unit, etc.

Your proposals are to either (a) replace that with an almost-as-buggy
SO_PASSCGROUP option or to add SO_PEERCGROUP.  The latter would allow
journald to figure out the cgroup that opened the socket.  The problem
here is two-fold.  One: systemd already knows the cgroup it intends to
use, and it can tell journald without kernel help.  Two: Systemd seems
to open the stdout socket right before setting the cgroup, so the
kernel's idea of what cgroup opened the socket is crap.

The solution to all of this seems straightforward: fix journald to use
the information it already has, trusted, without races, from systemd.

--Andy
