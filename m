From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 06/10] pktgen: new pktgen helper functions for
 samples scripts
Date: Thu, 21 May 2015 11:18:49 +0200
Message-ID: <20150521111849.283d230b@redhat.com>
References: <20150519213326.9070.18264.stgit@ivy>
	<20150519213608.9070.31995.stgit@ivy>
	<CAHA+R7NzKMLLZ954F+moZ7wFEFWPTBzo0Js9rGnU02kkPTPB0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>, brouer@redhat.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbbEUJT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 05:19:27 -0400
In-Reply-To: <CAHA+R7NzKMLLZ954F+moZ7wFEFWPTBzo0Js9rGnU02kkPTPB0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 May 2015 14:23:17 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Tue, May 19, 2015 at 2:36 PM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> > +
> > +# More generic replacement for pgset(), that does not depend on global
> > +# variable for proc file.
> > +function proc_cmd() {
> > +    local result
> > +    local proc_file=$1
> > +    # after shift, the remaining args are contained in $@
> > +    shift
> > +    local proc_ctrl=${PROC_DIR}/$proc_file
> > +    if [[ ! -e "$proc_ctrl" ]]; then
> > +       err 3 "proc file:$proc_ctrl does not exists (dev added to thread?)"
> > +    else
> > +       if [[ ! -w "$proc_ctrl" ]]; then
> > +           err 4 "proc file:$proc_ctrl not writable, not root?!"
> > +       fi
> > +    fi
> > +
> > +    if [[ "$DEBUG" == "yes" ]]; then
> > +       echo "cmd: $@ > $proc_ctrl"
> > +    fi
> > +    # Quoting of "$@" is important for space expansion
> > +    echo "$@" > "$proc_ctrl"
> > +    local status=$?

(For later, notice, extraction of $? here)

> > +
> > +    result=`cat $proc_ctrl | fgrep "Result: OK:"`
> 
> Nit: useless usage of cat, grep/fgrep accepts a file name.

True, I just copied it from the old pgset().  I also don't think
"fgrep" is really needed.

Replacing with:
  result=$(grep "Result: OK:" $proc_ctrl)

> 
> > +    if [[ "$result" == "" ]]; then
> 
> You can test $?

No, unfortunately not... this is because I'm also using the function
for /proc/net/pktgen/pgctrl which does not contain a "Result:" line.

Thus, I can reuse this function for pgctrl, by letting it pass this
test. And pgctrl didn't even return errors on false input (fixed in this
patchset), which made any feedback from pgctrl futile.


(RANT)
Do notice pktgen proc API of reading "Result: OK:" is broken in more
ways ... which I'm trying to handle here.

On some proc-input pktgen does not return an error, but writes the error
message in the proc file.  Thus, we MUST parse/grep "Result".

On some proc-input pktgen only returns and error, and does NOT update
the "result" output.  Thus, the result can contain a "Result: OK:"
from a previous command.  This was not detected by old pgset().

This is why I'm extracting status=$? earlier.


This new proc write function catches a very common configuration
sequence of input correct dst IP but wrong MAC addr.

See:
 # echo -e "dst 1.2.3.4.5.6" > eth4@0 ; cat eth4@0 | grep Result
 Result: OK: dst_min=1.2.3.4.5.6
 # echo -e "dst_mac in:va:id " > eth4@0 ; cat eth4@0 | grep Result
 -bash: echo: write error: Invalid argument
 Result: OK: dst_min=1.2.3.4.5.6



> > +       cat $proc_ctrl | fgrep Result: >&2
> > +    fi
> > +    if (( $status != 0 )); then
> > +       err 5 "Write error($status) occured cmd: \"$@ > $proc_ctrl\""
> 
> Typo: occurred

True, annoyingly I already fixed it in the backward compat pgset().

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
