From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 10:42:55 -0300
Message-ID: <20130219104255.3d01363a@redhat.com>
References: <20130218221306.GA21493@pd.tnic>
	<20130218222618.GA21818@kroah.com>
	<20130218224405.GB21493@pd.tnic>
	<20130219070310.2cadad7a@redhat.com>
	<20130219101121.GJ23197@arwen.pp.htv.fi>
	<20130219081149.46972f56@redhat.com>
	<20130219114345.GA26623@pd.tnic>
	<20130219091610.2b746a30@redhat.com>
	<20130219123502.GD26623@pd.tnic>
	<20130219094640.2abf1a66@redhat.com>
	<20130219130626.GE26623@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: balbi@ti.com, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130219130626.GE26623@pd.tnic>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, 19 Feb 2013 14:06:26 +0100
Borislav Petkov <bp@alien8.de> escreveu:

> > No, on both cases, open() will return an error (-ENOENT against -EPERM).
> 
> What if it is a shell script doing:
> 
> cat /sys/devices/system/edac/mc/mc0/sdram_scrub_rate
> 
> or similar?

Well, cat will return "1" if an error is found, no matter what error happened. 

With an existing file (-ENOSYS):

	$ cat /sys/devices/system/edac/mc/mc0/sdram_scrub_rate; echo $?

	cat: /sys/devices/system/edac/mc/mc0/sdram_scrub_rate: No such device
	1

When the file doesn't exist (-ENOENT):
	$ cat /sys/devices/system/edac/mc/mc0/sdram_scrub_rate_not_exist; echo $?
	cat: /sys/devices/system/edac/mc/mc0/sdram_scrub_rate_not_exist: No such file or directory
	1

When permission doesn't match (-EPERM):
	$ cat /sys/devices/system/cpu/probe; echo $?
	cat: /sys/devices/system/cpu/probe: Permission denied
	1

When everything is ok, it will return 0
	$ cat /sys/devices/system/edac/mc/mc0/ce_count; echo $? >/dev/null
	0

A script ready to handle -ENOSYS would be doing, instead:

	RATE=$(cat /sys/devices/system/edac/mc/mc0/ce_count 2>/dev/null)
	if [ "$?" == "0" ]; then echo "Scrub rate: $RATE"; fi

So, a bash script won't notice any difference.

The only difference will be noticed if the script is written on some other 
language and the script is dumb enough to assume success if the errno is
different than -ENOSYS.

-- 

Cheers,
Mauro
