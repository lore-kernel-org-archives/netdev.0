From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode
 with esp and ah hangs (problem is in xfrm_state_add)
Date: Sun, 30 Jan 2005 22:44:04 -0800
Message-ID: <20050130224404.5f78d28a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 30 Jan 2005 22:14:31 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)


http://bugme.osdl.org/show_bug.cgi?id=4138

           Summary: ipsec with racoon in transport mode with esp and ah
                    hangs (problem is in xfrm_state_add)
    Kernel Version: 2.6.10-1.8_FC2custom
            Status: NEW
          Severity: normal
             Owner: shemminger@osdl.org
         Submitter: au@unterluggauer.org


Distribution: FC2 (all updates)  
Hardware Environment: Intel Celeron, E1000 (or E100, or Broadcom)  
  
Software Environment:  
KAME IPSec-Tools (setkey and racoon) vers. 0.5rc2 (same with 0.4 or 0.2.5-4)   
Linux litiusoft 2.6.10-1.8_FC2custom #26 SMP Mon Jan 31 04:25:18 CET 2005 i686  
i686 i386 GNU/Linux  
  
Gnu C                  3.3.3  
Gnu make               3.80  
binutils               2.15.90.0.3  
util-linux             2.12  
mount                  2.12  
module-init-tools      2.4.26  
e2fsprogs              1.35  
reiserfsprogs          line  
reiser4progs           line  
quota-tools            3.10.  
nfs-utils              1.0.6  
Linux C Library        2.3.3  
Dynamic linker (ldd)   2.3.3  
Procps                 3.2.0  
Net-tools              1.60  
Kbd                    1.12  
Sh-utils               5.2.1  
Modules Loaded         esp4 ah4 twofish serpent aes_i586 blowfish sha256  
crypto_null af_key snd_intel8x0 snd_ac97_codec snd_pcm snd_timer  
snd_page_alloc snd soundcore usb_storage usbhid uhci_hcd ehci_hcd usbcore  
  
Problem Description:  
I am trying to use ipsec with esp and ah in transport mode between two hosts.  
Using only setkey with fixed spi and key for ah and esp is working.  
Using racoon with esp only (or ah only) in transport mode is working.  
Using racoon with esp and ah in transport mode is not working!  
  
  
Steps to reproduce:  
set policy at 192.168.2.3:  
#!/sbin/setkey  -f  
flush;  
spdflush;  
  
spdadd 192.168.2.5 192.168.2.3 any -P in ipsec  
   esp/transport//require  
   ah/transport//require;  
  
spdadd 192.168.2.3 192.168.2.5 any -P out ipsec  
   esp/transport//require  
   ah/transport//require;  
  
-------  
set policy at 192.168.2.5:  
#!/sbin/setkey  -f  
flush;  
spdflush;  
  
spdadd 192.168.2.3 192.168.2.5 any -P in ipsec  
   esp/transport//require  
   ah/transport//require;  
  
spdadd 192.168.2.5 192.168.2.3 any -P out ipsec  
   esp/transport//require  
   ah/transport//require;  
--------  
set racoon.conf on both machines:  
  
path pre_shared_key "/etc/racoon/psk.txt";  
  
remote anonymous  
{  
   exchange_mode main, aggressive;  
   doi ipsec_doi;  
   my_identifier address;  
   proposal_check strict;  
   proposal {  
       encryption_algorithm 3des;  
       hash_algorithm sha1;  
       authentication_method pre_shared_key;  
       dh_group 2;  
       lifetime time 2 hour;  
   }  
}  
  
sainfo anonymous  
{  
        pfs_group 2;  
        lifetime time 1 hour ;  
        encryption_algorithm 3des;  
        authentication_algorithm hmac_sha1 ;  
        compression_algorithm deflate ;  
}  
  
---------  
  
Notes:  
After a lot of plog() in the ipsec-tools source and a lot of printk() in the  
ipsec part of the kernel I come to the conclusion, that the problem is in the  
function xfrm_state_add():  
the following if statement in xfrm_state_add cause the problem:  
if (x->km.seq) {  
   x1 = __xfrm_find_acq_byseq(x->km.seq);  
   if (x1 && xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family)) {  
      xfrm_state_put(x1);  
      x1 = NULL;  
   }  
}  
if (!x1) {  
   ...  
}  
__xfrm_state_insert(x);  
...  
if (x1) {  
   xfrm_state_delete(x1);  
}  
  
the SAD entries for ah and esp have the same km.seq!   
__xfrm_find_acq_byseq() returns the first of them.  
  
the next if statement is false!!! because of the same daddr. x1 will not be  
set NULL.   
the next if (!x1) {} is also false.  
the last if (x1) is true and x1 will be deleted (although it hasn't been  
allocated)  
  
Workaround:  
I comment the if (x->km.seq) { ... } out. than it works vor me. but I know  
thats not a solution. 
 
now it's your turn :) 
andi

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
