From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Thu, 3 Jun 2004 19:33:03 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040604023303.GB7537@jm.kir.nu>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
	<20040602132313.GB7341@jm.kir.nu>
	<20040602155542.GC24822@ruslug.rutgers.edu>
	<20040603165233.GC8770@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, hostap@shmoo.com,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	prism54-devel@prism54.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040603165233.GC8770@bougret.hpl.hp.com>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 03, 2004 at 09:52:33AM -0700, Jean Tourrilhes wrote:

> 	So, the plan would be to take Jouni's API as is (or with minor
> modifications) and stuff that in wireless.h. I don't believe that the
> tools themselves need to be modified, because wpa_supplicant is the
> sole user of those ioctls.
> 	If you are all happy with that, then I'll just do it.

I'm mostly happy with this, but this should also include something from
the private ioctls hostapd uses for AP functionality. In addition, I
would consider changing couple of text based elements (e.g., WPA IE as
hex string) to binary in order to remove extra parsing code and make the
data contents smaller. I'm having quite a bit of problems with scan
results getting too large for the current limit of 4 kB.. Admittedly,
this is in a test lab environment, but still, it is annoying and
requires workarounds like driver side filtering of the scan results.

I could try to make a list of all private ioctls currently used in
wpa_supplicant and hostapd, including some comments on what I would
consider changing at this point (mostly, changing text binary for couple
of cases and removing some fields that are not really going to be used).
Main categories for new functionality would be:
- key configuration (multiple algorithms, individual/unicast keys,
  packet number set/get),
- WPA (or actually, generic) information element (get from scan results,
  set for (Re)AssocReq/Beacon/ProbeResp)
- MLME requests (deauth/disassoc; maybe associate, too; I'm currently
  using SIOCSIWAP for this; scan request with SSID (and maybe also
  channel list) for active scanning
- authentication mode/encryption algorithm parameters (Host AP driver
  does not current use this, but this is the way WPA drivers are used in
  Windows NDIS and some Linux driver authors prefered this option and
  wpa_supplicant supports it as an optional mechanism)
- some encryption related events/parameters (reporting Michael MIC
  errors, TKIP countermeasures, configuration of "drop unencrypted" and
  "privacy invoked").

Once we get some kind of testing version done, I will add a new driver
interface code for wpa_supplicant for the generic Linux wireless
extensions case and modify Host AP driver to use this. I hope that other
drivers would also start to use the new API at some point, although
wpa_supplicant is likely to maintain the backwards compatible interface
code for some time.

-- 
Jouni Malinen                                            PGP id EFC895FA
