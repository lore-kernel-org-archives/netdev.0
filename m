From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: softirq oops from b44_poll
Date: Mon, 07 Nov 2011 22:21:41 -0800
Message-ID: <1320733301.21617.3.camel@ppwaskie-mobl2>
References: <20111107205647.GC14216@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-umMvEba7cJ1OAEP2nHSY"
Cc: Gary Zambrano <zambrano@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-team@fedoraproject.org" <kernel-team@fedoraproject.org>
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35940 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab1KHGVt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 01:21:49 -0500
In-Reply-To: <20111107205647.GC14216@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-umMvEba7cJ1OAEP2nHSY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-11-07 at 12:56 -0800, Josh Boyer wrote:
> Hi all,
>=20
> We've had two reports of a WARN_ON being spit out from kernel/softirq.c
> that seem fairly related in symptoms.  Both seem to involved b44_poll
> either during the middle of some disk I/O.  An example of the output is
> here:
>=20
> :WARNING: at kernel/softirq.c:159 _local_bh_enable_ip+0x44/0x8e()
> :Hardware name: Vostro 1500                    =20
> :Modules linked in: fuse lockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ip=
v6
> ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
> nf_conntrack sunrpc uinput snd_hda_codec_idt snd_hda_intel snd_hda_codec
> snd_hwdep snd_seq snd_seq_device snd_pcm dell_wmi sparse_keymap dell_lapt=
op
> joydev dcdbas microcode r852 sm_common nand nand_ids b44 nand_ecc r592 mt=
d ssb
> mii memstick arc4 i2c_i801 iTCO_wdt iTCO_vendor_support iwl3945 iwl_legac=
y
> mac80211 cfg80211 rfkill snd_timer snd soundcore snd_page_alloc firewire_=
ohci
> firewire_core crc_itu_t uas usb_storage sdhci_pci sdhci mmc_core nouveau =
ttm
> drm_kms_helper drm i2c_algo_bit i2c_core mxm_wmi wmi video [last unloaded=
:
> scsi_wait_scan]
> :Pid: 1511, comm: nepomukservices Not tainted 3.1.0-1.fc16.x86_64 #1
> :Call Trace:
> : <IRQ>  [<ffffffff81057a56>] warn_slowpath_common+0x83/0x9b
> : [<ffffffff81057a88>] warn_slowpath_null+0x1a/0x1c
> : [<ffffffff8105d462>] _local_bh_enable_ip+0x44/0x8e
> : [<ffffffff8105d4ba>] local_bh_enable_ip+0xe/0x10
> : [<ffffffff814b5af4>] _raw_spin_unlock_bh+0x15/0x17
> : [<ffffffffa03cc969>] destroy_conntrack+0x9d/0xdc [nf_conntrack]
> : [<ffffffff813fa083>] nf_conntrack_destroy+0x19/0x1b
> : [<ffffffff813ce4ed>] skb_release_head_state+0xa7/0xef
> : [<ffffffff813ce2f1>] __kfree_skb+0x13/0x83
> : [<ffffffff813ce3b7>] consume_skb+0x56/0x6b
> : [<ffffffffa02e48c4>] b44_poll+0xaf/0x3ec [b44]
> : [<ffffffff813d8137>] net_rx_action+0xa9/0x1b8
> : [<ffffffffa02e202e>] ? br32+0x19/0x1d [b44]
> : [<ffffffff8105d6b3>] __do_softirq+0xc9/0x1b5
> : [<ffffffff81027719>] ? ack_APIC_irq+0x15/0x17
> : [<ffffffff814be32c>] call_softirq+0x1c/0x30
> : [<ffffffff81010b45>] do_softirq+0x46/0x81
> : [<ffffffff8105d97b>] irq_exit+0x57/0xb1
> : [<ffffffff814bec0e>] do_IRQ+0x8e/0xa5
> : [<ffffffff814b5d2e>] common_interrupt+0x6e/0x6e
> : <EOI>  [<ffffffff814bc1f4>] ? sysret_audit+0x16/0x20
>=20
> You can find the original bug reports in the URLs below.  This has happen=
ed
> on two different machines, one 32-bit and another 64-bit.  I'm fairly sur=
e
> both reports are the same issue, but I haven't a clue what that issue mig=
ht
> be at the moment.
>=20
> Thoughts?

I don't have the hardware to play with, but from inspection, I suspect a
thread is getting stuck on that CPU from the spin_lock_irqsave() in
b44_poll().  There are some calls that are mapping and unmapping memory,
which could be blocking.  NAPI should be offering protection under
softirq context, so I'm not sure why that spinlock is even there.  And
comparing with a number of other NAPI poll routines in other drivers,
they are also not locking.

This is entirely a theory that I can't test though.

Cheers,
-PJ

> https://bugzilla.redhat.com/show_bug.cgi?id=3D749856
> https://bugzilla.redhat.com/show_bug.cgi?id=3D741117
>=20
> josh
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
LAN Access Division, Intel Corporation

--=-umMvEba7cJ1OAEP2nHSY
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPAjCCAz0w
ggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1
aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTA2
MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVs
IENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kgQ0EwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATDIsV2xDyt
30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUjZzTZFq2N
4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZvuSQ0E11y
YL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4lz36wOdN
Zn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+iC1HawJd
AgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0Vgaj7TdU
DDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNh
LmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69tOkIP4Sg
DJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3jMfr900fX
ZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAAAAAACDAN
BgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24x
JzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUxOTI3MjZa
Fw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jwb3JhdGlv
bjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUdHvWG+IcQ
HVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jXEfTBvTnU
SFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa4k6YN94z
lrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigiF2kEn9xV
h1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38CAwEAAaOC
AlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYxMCvFMAsG
A1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2ekKQ/5Kt
im+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdv
qNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3klMjBDQS5j
cmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIw
RXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYI
KwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcwAoZgaHR0
cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwl
MjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCx
tQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1cChqpb22
U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFWpy7rB3Vm
/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjskTENPmhb
VbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8RHCJXkPa
u/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGLzCCBRegAwIBAgIKf0es/QABAABRFTANBgkq
hkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwNDA5MDgyNzMw
WhcNMTMwMzI0MDgyNzMwWjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQZXRlciBQMS4wLAYJ
KoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAxNvzDG+qS7UFSaYiqMqQr7exXHirCVe1tapLZoFlJZLPfqZsBsAA
UqARnY+v3RQj3WDmoIOtTMHxtnmo4pd5UXrsk+PraedGAilso9tkfp5ZjRjZo9LL06AZzjiBVfAx
gvyxMPsoKhdfFijzqSJRpc12kB662PAJWfyJO+f6lg5+Cd4KgRVGrpGI4bvBKEVGMeOqwD+kcVti
wRcqNygx35GqdcpJCCJqOSAJsLI3DR7tDvATeNzsasweaHgWonaK4D6qaHkoGx4VHknC6uNn/FK/
wXtFbXkeOrnRGJIzaZNsOBVhTou9w3NYU1EjuK75hZJ4Fd4/r1gHafxWD+VzrwIDAQABo4IDAjCC
Av4wCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWO
n1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFLtB44dRTSgY1071RY+nMiKRkn1PMB8GA1Ud
IwQYMBaAFA7GKvdZsggQkCVvw939imYxMCvFMIHPBgNVHR8EgccwgcQwgcGggb6ggbuGV2h0dHA6
Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUy
MElzc3VpbmclMjBDQSUyMDNCKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20v
cmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIw
M0IoMSkuY3JsMIH1BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3dy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIw
SXNzdWluZyUyMENBJTIwM0IoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlmaWNhdGVz
LmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFz
aWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBYea1KThIl9gNf
1uIob1trWtsthhWAXsdUu1V+gl10RBChuM4okZccJf1JXItFA2z7J2UR4cu/tRZBRFartVPhGBjK
ntLofxsaW7wwzfsinbNy30gHGShG83XDADdGUteL8PmupDcDf/MtbRIlfjEknLiuOnrM25WVajtB
3fB1pOA2jmLaaNmasza9ordaD3afJD3IWr/Zj+aevMu4zrKzwdOZqBZW1J1Qc7uog8Mn+mm+wRMm
EY0z7VFdjsZjJH9EQA0UbF1aYcshv0a/M2deKN9TdYuJ1eTKRSZdzSiRG5w75xujFMYZgo4ETlu1
Behgey1jvJiyWdOsPt7at08QMYIB6jCCAeYCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMR
SW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vpbmcg
Q0EgM0ICCn9HrP0AAQAAURUwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTExMTEwODA2MjE0MVowIwYJKoZIhvcNAQkEMRYEFKZgo+1vtmCWFhZt
m7tJ6y7nwwiWMA0GCSqGSIb3DQEBAQUABIIBAMQVSCGTuegHvTWUR0aeRp38ZF9+Fk6ueCbiAmKA
Lx8KQO6l2KgUh82Stflp6BxmPS6UjRx8ImaLpT1o7U3dVKT3rr1tEaLyEcVDgXSN1N2JRRoAwQl8
7o5jDlhsGXtCKjoubCjhzHKy2epIwRT7aAAIz7IpRuh7iBVT4VmxX34xiTx3oGLG7JkEe4X9gctZ
ikTIpO6vgN/6n40UGO8eD0z5A/l4lKyFnmY9tfU9tLkran2cQKxv0p3xhhX5dGbTSCv6TOg7+Q1a
l9FSzO1opkMSVbR5tYzeW4E0d2VlUabPchqbD7mqi2Frb5wKft1M/M2CbgExRK3HQRjuWsyx1jsA
AAAAAAA=


--=-umMvEba7cJ1OAEP2nHSY--
