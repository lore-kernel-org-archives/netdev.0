From: Yan Zheng <yzcorp@gmail.com>
Subject: Re: [PATCH][MCAST]Two fix for implementation of MLDv2 .
Date: Fri, 4 Nov 2005 14:19:43 +0800
Message-ID: <7e77d27c0511032219g43b6d015w@mail.gmail.com>
References: <7e77d27c0511030526g45d8f6e6l@mail.gmail.com>
	 <OF70243A3E.F658C3A4-ON882570AF.001699E7-882570AF.0018C8DB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161081AbVKDGTo@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF70243A3E.F658C3A4-ON882570AF.001699E7-882570AF.0018C8DB@us.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>         So, I'll look at this more carefully and see if I still agree
> it needs a fix and whether or not your patch, or some alternative
> method might be more appropriate. But it'll probably be sometime
> next week before I'll be done reviewing/considering alternatives on
> this one.
>
>                                         +-DLS
>
>


I am sorry, I can't understand your opinion completely.
Please forgive my poor english :-)

Here is my  opinion:

I think Multicast Address and Source Specific Query is sent only when
router want to block traffic from some source.  So when the filter
mode is exclude, node should send a report which includes a
MODE_IS_INCLUDE Record with sources in the query but NOT in the
filter's source list. This is the required behaviour in rfc3810, but
it need addiction item in struct ifmcaddr6 to record sources in the
query.  So I think make process Multicast Address Specific Query and
Multicast Address and Source Specific Query no difference is a
temporary fix.

the secoend change in is_in(...) is because I think include/exclude
counts also should be checked when type is MLD2_MODE_IS_INCLUDE or
MLD2_MODE_IS_EXCLUDE.



Regards

Here is my modify version is_in(...)
-----------------------------------------------------------------------------------------------
static int is_in(struct ifmcaddr6 *pmc, struct ip6_sf_list *psf, int type,
	int gdeleted, int sdeleted)
{
	switch (type) {
	case MLD2_MODE_IS_INCLUDE:
	case MLD2_CHANGE_TO_INCLUDE:
		if (gdeleted || sdeleted)
			return 0;
		if (psf->sf_count[MCAST_INCLUDE] == 0)
			return 0;    // maybe never happen
		if (type == MLD2_CHANGE_TO_INCLUDE)
			return 1;
		return !((pmc->mca_flags & MAF_GSQUERY) && !psf->sf_gsresp);
	case MLD2_MODE_IS_EXCLUDE:
	case MLD2_CHANGE_TO_EXCLUDE:
		if (gdeleted || sdeleted)
			return 0;
		if (pmc->mca_sfcount[MCAST_EXCLUDE] == 0 ||
		    psf->sf_count[MCAST_INCLUDE])
			return 0;
		return pmc->mca_sfcount[MCAST_EXCLUDE] ==
			psf->sf_count[MCAST_EXCLUDE];
	case MLD2_ALLOW_NEW_SOURCES:
		if (gdeleted || !psf->sf_crcount)
			return 0;
		return (pmc->mca_sfmode == MCAST_INCLUDE) ^ sdeleted;
	case MLD2_BLOCK_OLD_SOURCES:
		if (pmc->mca_sfmode == MCAST_INCLUDE)
			return gdeleted || (psf->sf_crcount && sdeleted);
		return psf->sf_crcount && !gdeleted && !sdeleted;
	}
	return 0;
}
