From: Yan Zheng <yzcorp@gmail.com>
Subject: Re: [PATCH][MCAST]Two fix for implementation of MLDv2 .
Date: Thu, 3 Nov 2005 09:22:04 +0800
Message-ID: <7e77d27c0511021722l6bb768c7h@mail.gmail.com>
References: <436878E7.3030303@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030249AbVKCBWF@vger.kernel.org>
To: Yan Zheng <yanzheng@21cn.com>
In-Reply-To: <436878E7.3030303@21cn.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find something interesting .  Maybe more changes for is_in(...) are needed.


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
		if (type == MLD2_MODE_IS_EXCLUDE)
			return 1;
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
