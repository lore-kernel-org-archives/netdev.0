From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT,
 expected EINVAL/ENOTTY
Date: Fri, 8 Dec 2006 09:50:55 -0800
Message-ID: <20061208095055.38fef768@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:42295 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758255AbWLHRu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 12:50:57 -0500
Received: from localhost (outside0.osdl.org [65.172.181.23])
	(authenticated bits=0)
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id kB8HotID021294
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 8 Dec 2006 09:50:56 -0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 5 Dec 2006 08:55:19 -0800
From: bugme-daemon@bugzilla.kernel.org
To: shemminger@osdl.org
Subject: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT, expected EINVAL/ENOTTY


http://bugzilla.kernel.org/show_bug.cgi?id=7635

           Summary: ioctl(fd,TCSBRK,1) on socket yields EFAULT, expected
                    EINVAL/ENOTTY
    Kernel Version: 2.6.15
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: Joerg-Cyril.Hoehle@T-Systems.com


Most recent kernel where this bug did *NOT* occur: unknown
Distribution: Ubuntu Dapper, but confirmed from some others distros as well.
Hardware environment: Fujitsu Siemens Lifebook C1110, i686 centrino laptop
Software environment: ubuntu Gnome desktop, sshd, netcat

Problem description:
ioctl(TCSBRK) yields EFAULT when invoked on a socket.  An error is to
be expected, but not an address error, which is an indication of a serious
fault. EINVAL or ENOTTY are typical and acceptable errno values as the
following summary shows
(and EOPNOTSUPP also seems possible on Darwin Mac OS X).

This bug affects tcdrain(3), because tcdrain(fd) is equivalent to
ioctl(fd,TCSBRK,1) on Linux and Solaris.

ioctl(TCSBRK,1)	errno
pty		0
pipe		22/EINVAL
/dev/null	25/ENOTTY
reg_file	25/ENOTTY
socket		14/EFAULT

kernel version:
Linux version 2.6.15-27-686 (buildd@terranova) (gcc version 4.0.3 (Ubuntu
4.0.3-1ubuntu5)) #1 SMP PREEMPT Sat Sep 16 02:13:27 UTC 2006

Steps to reproduce:
/* tcdrain() returns EFAULT (a serious error) on sockets
 * tcdrain() is equivalent to ioctl(TCSBRK) on Linux and Solaris
 */
#include <sys/ioctl.h>
#include <termios.h>            /* TCSBRK is 0x5409 */
#include <errno.h>
#include <string.h>
#include <stdio.h>

int main () {
  int i;
  for (i=0; i<=2; i++) {
    int retval, save;
    errno = 0;
    retval = ioctl(i,TCSBRK,1);
    save = errno;
    /* printf("ioctl(%d,TCSBRK,1)=(%d,%d)\n",i,retval,save); */
    printf("ioctl(%d,TCSBRK,1)=(%d,%d=%s)\n",i,retval,save,
	   save ? strerror(save) : "");
  }
  return 0;
}

sample output:
$ ~/Bugs/ioctl-tcsbrk
ioctl(0,TCSBRK,1)=(0,0=)
ioctl(1,TCSBRK,1)=(0,0=)
ioctl(2,TCSBRK,1)=(0,0=)
$ ~/Bugs/ioctl-tcsbrk | cat
ioctl(0,TCSBRK,1)=(0,0=)
ioctl(1,TCSBRK,1)=(-1,22=Invalid argument)
ioctl(2,TCSBRK,1)=(0,0=)
$ ~/Bugs/ioctl-tcsbrk < /dev/null
ioctl(0,TCSBRK,1)=(-1,25=Inappropriate ioctl for device)
ioctl(1,TCSBRK,1)=(0,0=)
ioctl(2,TCSBRK,1)=(0,0=)
$ ~/Bugs/ioctl-tcsbrk < ~/Bugs/ioctl-tcsbrk
ioctl(0,TCSBRK,1)=(-1,25=Inappropriate ioctl for device)
ioctl(1,TCSBRK,1)=(0,0=)
ioctl(2,TCSBRK,1)=(0,0=)

$ nc -l -p 50000 -c ~/Bugs/ioctl-tcsbrk
$ telnet localhost 50000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
ioctl(0,TCSBRK,1)=(-1,14=Bad address)
ioctl(1,TCSBRK,1)=(-1,14=Bad address)
ioctl(2,TCSBRK,1)=(-1,14=Bad address)
Connection closed by foreign host.

/proc/cpuinfo:
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 13
model name	: Intel(R) Pentium(R) M processor 1.60GHz
stepping	: 6
cpu MHz		: 1600.175
cache size	: 2048 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr mce cx8 apic sep mtrr pge mca cmov pat clflush
dts acpi mmx fxsr sse sse2 ss tm pbe est tm2
bogomips	: 1201.01

$ lsmod (shortened a little)
Module                  Size  Used by
acpi_sbs               20172  0 
i2c_acpi_ec             5120  1 acpi_sbs
i2c_core               22848  1 i2c_acpi_ec
battery                 9988  1 acpi_sbs
ac                      5220  1 acpi_sbs
thermal                13768  0 
fan                     4836  0 
button                  6704  0 
ipw2200               113548  0 
ieee80211              38952  1 ipw2200
...
8139too                29056  0 
nls_utf8                2240  0 
nls_cp437               5888  0 
vfat                   14496  0 
fat                    55548  1 vfat
sg                     40160  0 
sd_mod                 20448  0 
usb_storage            79648  0 
scsi_mod              145960  3 sg,sd_mod,usb_storage
joydev                 10432  0 
rfcomm                 43604  0 
l2cap                  28192  5 rfcomm
bluetooth              54212  4 rfcomm,l2cap
i915                   21664  1 
drm                    78484  2 i915
ppdev                   9668  0 
speedstep_centrino      8752  1 
cpufreq_powersave       1920  0 
cpufreq_stats           6688  0 
cpufreq_userspace       6496  1 
cpufreq_ondemand        7752  0 
cpufreq_conservative     9000  0 
freq_table              4928  2 speedstep_centrino,cpufreq_stats
tc1100_wmi              6884  0 
video                  16324  0 
container               4608  0 
pcc_acpi               12416  0 
sony_acpi               5580  0 
dev_acpi               11236  0 
hotkey                 11492  0 
ipv6                  286976  22 
ext3                  148296  2 
jbd                    65876  1 ext3
dm_mod                 63256  1 
af_packet              24520  2 
lp                     12356  0 
pcmcia                 41948  0 
tsdev                   8032  0 
parport_pc             37988  1 
parport                39400  3 ppdev,lp,parport_pc
pcspkr                  2244  0 
8139cp                 24032  0 
mii                     6176  2 8139too,8139cp
yenta_socket           30124  2 
rsrc_nonstatic         14624  1 yenta_socket
pcmcia_core            45272  3 pcmcia,yenta_socket,rsrc_nonstatic
snd_intel8x0           35772  2 
...
snd_page_alloc         11304  2 snd_intel8x0,snd_pcm
psmouse                40004  0 
serio_raw               7748  0 
shpchp                 49504  0 
pci_hotplug            30788  1 shpchp
hw_random               5716  0 
intel_agp              24700  1 
agpgart                36784  3 drm,intel_agp
evdev                  10176  1 
reiserfs              284016  2 
ide_generic             1504  0 
ehci_hcd               36104  0 
uhci_hcd               35536  0 
usbcore               139172  4 usb_storage,ehci_hcd,uhci_hcd
ide_cd                 35780  0 
cdrom                  41408  1 ide_cd
ide_disk               19136  6 
piix                   11652  1 
generic                 5124  0 
processor              26888  2 thermal,speedstep_centrino
capability              4968  0 
commoncap               7328  1 capability
vga16fb                13992  1 
...
softcursor              2304  1 bitblit

Regards,
 Joerg Hoehle

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.
